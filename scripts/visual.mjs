import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { chromium } from 'playwright';
import pixelmatch from 'pixelmatch';
import { PNG } from 'pngjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const REFERENCE = join(ROOT, 'reference');

async function main() {
  const args = process.argv.slice(2);
  const update = args.includes('--update');
  const onlyIndex = args.indexOf('--only');
  const only = onlyIndex === -1 ? null : args[onlyIndex + 1];

  if (onlyIndex !== -1 && (!only || only.startsWith('--'))) {
    throw new Error('--only requiere el nombre de una página.');
  }

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

  const baseUrl = (process.env.PREVIEW_URL || process.env.STORE_URL || '')
    .replace(/\/+$/, '');
  const threshold = Number(process.env.VISUAL_THRESHOLD ?? 0.01);

  if (!baseUrl) {
    throw new Error('Configurá PREVIEW_URL o STORE_URL para ejecutar visual.');
  }

  if (!Number.isFinite(threshold) || threshold < 0 || threshold > 1) {
    throw new Error('VISUAL_THRESHOLD debe ser una proporción entre 0 y 1.');
  }

  const output = update ? REFERENCE : join(REFERENCE, '_current');
  const diffDirectory = join(REFERENCE, '_diff');

  await mkdir(output, { recursive: true });

  if (!update) {
    await mkdir(diffDirectory, { recursive: true });
  }

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
        let context;

        try {
          context = await browser.newContext({
            viewport: { width: viewport.width, height: viewport.height },
          });
          const page = await context.newPage();

          await page.goto(`${baseUrl}/${pageConfig.path.replace(/^\/+/, '')}`, {
            waitUntil: 'networkidle',
          });
          await page.waitForTimeout(1000);

          const screenshot = await page.screenshot({
            path: join(output, filename),
            fullPage: true,
            animations: 'disabled',
            caret: 'hide',
          });

          if (update) {
            result.estado = 'Referencia actualizada';
          } else {
            let reference;

            try {
              reference = PNG.sync.read(await readFile(join(REFERENCE, filename)));
            } catch (error) {
              if (error.code === 'ENOENT') {
                throw new Error('Falta referencia');
              }

              throw error;
            }

            const current = PNG.sync.read(screenshot);

            if (reference.width !== current.width || reference.height !== current.height) {
              throw new Error('Tamaños diferentes');
            }

            const diff = new PNG({ width: current.width, height: current.height });
            const differentPixels = pixelmatch(
              reference.data, current.data, diff.data, current.width, current.height,
            );
            const ratio = differentPixels / (current.width * current.height);

            await writeFile(join(diffDirectory, filename), PNG.sync.write(diff));
            result.diferencia = `${(ratio * 100).toFixed(4)}%`;
            result.estado = ratio > threshold ? 'Falla' : 'OK';
            failed ||= ratio > threshold;
          }
        } catch (error) {
          result.estado = error.message;
          failed = true;
        } finally {
          if (context) {
            await context.close();
          }
        }

        results.push(result);
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
