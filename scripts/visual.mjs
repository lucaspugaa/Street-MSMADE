import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { chromium } from 'playwright';
import pixelmatch from 'pixelmatch';
import { PNG } from 'pngjs';
import { createSimulation } from './lib/simulate.mjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const REFERENCE = join(ROOT, 'reference');

// Uso:
//   npm run visual              preview del tema de trabajo vs reference/ (capturas fijas)
//   npm run visual -- --live    preview vs TEST publicado capturado en el momento (sin deriva de stock/precios)
//   npm run visual:update       regenera reference/ desde TEST publicado
//   npm run visual -- --simulate  sin push: TEST publicado + migración aplicada en el navegador local (scripts/lib/simulate.mjs)
//   --only <página>             filtra por nombre de página de visual.config.json

function pageUrl(baseUrl, path, themeId) {
  const url = new URL(path.replace(/^\/+/, ''), `${baseUrl}/`);

  if (themeId) {
    url.searchParams.set('theme_installation_id', themeId);
  }

  return url.href;
}

function parseArgs(argv) {
  const onlyIndex = argv.indexOf('--only');
  const only = onlyIndex === -1 ? null : argv[onlyIndex + 1];

  if (onlyIndex !== -1 && (!only || only.startsWith('--'))) {
    throw new Error('--only requiere el nombre de una página.');
  }

  return { update: argv.includes('--update'), live: argv.includes('--live'), simulate: argv.includes('--simulate'), only };
}

// Recorre la página para disparar lazy-load e IntersectionObserver, y vuelve arriba.
/* global window, document -- este bloque corre dentro del navegador vía page.evaluate */
async function autoScroll(page) {
  await page.evaluate(async () => {
    const step = Math.max(200, Math.floor(window.innerHeight * 0.8));

    for (let y = 0; y < document.documentElement.scrollHeight; y += step) {
      window.scrollTo(0, y);
      await new Promise(resolve => setTimeout(resolve, 150));
    }

    window.scrollTo(0, 0);
  });
}

async function settle(page, stability) {
  await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});

  for (const text of stability.waitUntilGone ?? []) {
    await page.getByText(text).first()
      .waitFor({ state: 'hidden', timeout: 20000 })
      .catch(() => console.warn(`  aviso: sigue visible "${text}"`));
  }

  // Segunda pasada: el contenido que se armó recién (cards, carruseles) también tiene imágenes lazy.
  await autoScroll(page);
  await page.waitForLoadState('networkidle', { timeout: 15000 }).catch(() => {});
  await waitForImages(page);
  await page.waitForTimeout(1000);
}

async function waitForImages(page) {
  await page.evaluate(async () => {
    // El tema usa lazysizes (.lazyload) y el lazy de Swiper (.swiper-lazy): se fuerzan para que todo esté en la captura.
    document.querySelectorAll('img[loading="lazy"]').forEach(image => { image.loading = 'eager'; });

    if (window.lazySizes) {
      document.querySelectorAll('.lazyload').forEach(element => window.lazySizes.loader.unveil(element));
    }

    document.querySelectorAll('.swiper-lazy').forEach(image => {
      if (image.dataset.srcset) image.srcset = image.dataset.srcset;
      if (image.dataset.src) image.src = image.dataset.src;
      image.classList.add('swiper-lazy-loaded');
      image.parentElement?.querySelector('.swiper-lazy-preloader')?.remove();
    });

    const pending = [...document.images]
      .filter(image => !image.complete)
      .map(image => new Promise(resolve => {
        image.addEventListener('load', resolve, { once: true });
        image.addEventListener('error', resolve, { once: true });
      }));
    await Promise.race([Promise.all(pending), new Promise(resolve => setTimeout(resolve, 15000))]);
  });
}

async function capture(browser, { url, viewport, stability, path, transform }) {
  const context = await browser.newContext({
    viewport: { width: viewport.width, height: viewport.height },
  });

  try {
    // Reloj fijo: contadores y fechas salen iguales en cada corrida.
    if (stability.fixedTime) {
      await context.clock.setFixedTime(new Date(stability.fixedTime));
    }

    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(`pageerror: ${error.message}`));
    const blocked = new Set();
    page.on('console', message => {
      // Los requests que corta la propia captura (blockUrlPatterns) no cuentan como error del tema.
      if (message.type() === 'error' && !blocked.has(message.location()?.url)) errors.push(`console: ${message.text()}`);
    });

    // Requests que se cortan para que la captura sea determinista (p. ej. el scroll infinito del listado).
    for (const pattern of stability.blockUrlPatterns ?? []) {
      await page.route(new RegExp(pattern), route => {
        blocked.add(route.request().url());
        return route.abort();
      });
    }

    // Solo en --simulate: se reescribe el HTML del documento en este navegador; a la tienda no se le envía nada.
    if (transform) {
      await page.route(url, async route => {
        if (!route.request().isNavigationRequest()) return route.continue();
        const response = await route.fetch();
        const headers = { ...response.headers() };
        delete headers['content-length'];
        delete headers['content-encoding'];
        const body = await transform(await response.text());
        if (process.env.SIMULATE_DUMP) await writeFile(path.replace(/\.png$/, '.html'), body);
        return route.fulfill({ response, headers, body });
      });
    }

    await page.goto(url, { waitUntil: 'networkidle', timeout: 60000 });

    const hidden = stability.hideSelectors?.length
      ? `${stability.hideSelectors.join(',')} { display: none !important; }`
      : '';

    if (hidden || stability.extraCss) {
      await page.addStyleTag({ content: `${hidden}
${stability.extraCss ?? ''}` });
    }

    await autoScroll(page);
    await settle(page, stability);

    const screenshot = await page.screenshot({
      path,
      fullPage: true,
      animations: 'disabled',
      caret: 'hide',
      mask: (stability.maskSelectors ?? []).map(selector => page.locator(selector)),
    });

    return { screenshot, errors };
  } finally {
    await context.close();
  }
}

function compare(referenceBuffer, currentBuffer) {
  const reference = PNG.sync.read(referenceBuffer);
  const current = PNG.sync.read(currentBuffer);

  if (reference.width !== current.width || reference.height !== current.height) {
    return {
      error: `Tamaños diferentes (${reference.width}x${reference.height} vs ${current.width}x${current.height})`,
    };
  }

  const diff = new PNG({ width: current.width, height: current.height });
  const differentPixels = pixelmatch(
    reference.data, current.data, diff.data, current.width, current.height,
  );

  return { ratio: differentPixels / (current.width * current.height), diff: PNG.sync.write(diff) };
}

async function main() {
  const { update, live, simulate, only } = parseArgs(process.argv.slice(2));

  try {
    process.loadEnvFile(join(ROOT, '.env'));
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }

  const config = JSON.parse(
    await readFile(new URL('./visual.config.json', import.meta.url), 'utf8'),
  );
  const stability = config.stability ?? {};
  const selected = config.pages.filter(page => !only || page.name === only);

  if (selected.length === 0) {
    throw new Error(`No existe la página: ${only}`);
  }

  const pages = selected.filter(page => {
    if (page.path === null) {
      console.warn(`Se saltea ${page.name}: falta configurar path.`);
      return false;
    }

    return true;
  });

  if (pages.length === 0) {
    return;
  }

  // Las referencias salen de la tienda publicada (TEST); la comparación, de la preview del tema de trabajo.
  const storeUrl = process.env.STORE_URL?.replace(/\/+$/, '');
  const previewUrl = (process.env.PREVIEW_URL || storeUrl)?.replace(/\/+$/, '');
  const themeId = process.env.PREVIEW_THEME_ID;
  const threshold = Number(process.env.VISUAL_THRESHOLD ?? 0.001);

  if (!storeUrl || (!update && !simulate && !process.env.PREVIEW_URL && !themeId)) {
    throw new Error('Configurá STORE_URL (y PREVIEW_URL o PREVIEW_THEME_ID para comparar) en .env.');
  }

  if (!Number.isFinite(threshold) || threshold < 0 || threshold > 1) {
    throw new Error('VISUAL_THRESHOLD debe ser una proporción entre 0 y 1.');
  }

  const referenceDirectory = live ? join(REFERENCE, '_live') : REFERENCE;
  const currentDirectory = join(REFERENCE, '_current');
  const diffDirectory = join(REFERENCE, '_diff');

  await mkdir(referenceDirectory, { recursive: true });

  if (!update) {
    await mkdir(currentDirectory, { recursive: true });
    await mkdir(diffDirectory, { recursive: true });
  }

  const simulation = simulate ? await createSimulation(ROOT) : null;
  if (simulation) console.log(`Simulación: ${[...simulation.replacements.values()].flat().length} bloques migrados`);

  const browser = await chromium.launch();
  const results = [];
  let failed = false;

  try {
    for (const pageConfig of pages) {
      for (const viewport of config.viewports) {
        const filename = `${pageConfig.name}-${viewport.name}.png`;
        const result = {
          página: pageConfig.name,
          viewport: viewport.name,
          diferencia: '-',
          estado: '',
        };

        try {
          let referenceBuffer;

          if (update || live) {
            ({ screenshot: referenceBuffer } = await capture(browser, {
              url: pageUrl(storeUrl, pageConfig.path, null),
              viewport,
              stability,
              path: join(referenceDirectory, filename),
            }));
          }

          if (update) {
            result.estado = 'Referencia actualizada';
          } else {
            if (!referenceBuffer) {
              referenceBuffer = await readFile(join(REFERENCE, filename)).catch(error => {
                if (error.code === 'ENOENT') {
                  throw new Error('Falta referencia');
                }

                throw error;
              });
            }

            const { screenshot: currentBuffer, errors } = await capture(browser, {
              url: simulate
                ? pageUrl(storeUrl, pageConfig.path, null)
                : pageUrl(previewUrl, pageConfig.path, process.env.PREVIEW_URL ? null : themeId),
              transform: simulation?.transform,
              viewport,
              stability,
              path: join(currentDirectory, filename),
            });
            // Un módulo roto puede no cambiar la imagen: los errores de consola también hacen fallar la página.
            if (errors.length) {
              throw new Error(`Errores en consola (${errors.length}): ${errors.slice(0, 2).join(' | ')}`);
            }

            const comparison = compare(referenceBuffer, currentBuffer);

            if (comparison.error) {
              throw new Error(comparison.error);
            }

            await writeFile(join(diffDirectory, filename), comparison.diff);
            result.diferencia = `${(comparison.ratio * 100).toFixed(4)}%`;
            result.estado = comparison.ratio > threshold ? 'Falla' : 'OK';
            failed ||= comparison.ratio > threshold;
          }
        } catch (error) {
          result.estado = error.message;
          failed = true;
        }

        results.push(result);
        console.log(`${result.página} · ${result.viewport}: ${result.estado} ${result.diferencia}`);
      }
    }
  } finally {
    await browser.close();
    console.table(results);
  }

  if (failed) {
    process.exitCode = 1;
  }
}

main().catch(error => {
  console.error(`Visual: ${error.message}`);
  process.exitCode = 1;
});
