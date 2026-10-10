/* global DOMParser */
import { chromium } from 'playwright';
import { setTimeout as pause } from 'node:timers/promises';
import { resolve } from 'node:path';
import { CSV_PATH, ROOT, REQUIRED, isMain, readCSV, serializeCSV, writeAtomic } from './csv.mjs';

// DOMParser se usa sobre HTML inerte; no ejecuta scripts ni solicita imágenes.
export async function parseProducts(page, html, baseUrl) {
  return page.evaluate(({ html, baseUrl }) => {
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const cards = doc.querySelectorAll('.js-product-item-private, .js-item-product');
    const products = [];
    for (const card of cards) {
      const link = card.querySelector('.js-product-item-image-link-private, .product-item-link, a[href*="/productos/"]');
      if (!link) {
        continue;
      }
      const url = new URL(link.getAttribute('href'), baseUrl);
      const match = /^\/productos\/([^/]+)\/?$/.exec(url.pathname);
      if (!match || url.origin !== new URL(baseUrl).origin) {
        continue;
      }
      const name = card.querySelector('.js-item-name, .product-item-name')?.textContent.trim()
        || link.getAttribute('title') || link.getAttribute('aria-label') || '';
      const img = card.querySelector('img:not(.js-product-item-secondary-image-private):not(.product-item-image-secondary)');
      let cover = '';
      for (const attribute of ['src', 'data-src', 'data-srcset', 'srcset']) {
        const raw = img?.getAttribute(attribute)?.split(',')[0].trim().split(/\s+/)[0];
        if (raw && !raw.startsWith('data:')) {
          const resolved = new URL(raw, baseUrl);
          if (['http:', 'https:'].includes(resolved.protocol)) {
            cover = resolved.href;
            break;
          }
        }
      }
      if (!name || !cover) {
        throw new Error(`No se pudo leer nombre o portada del producto ${match[1]}. No se modificó la planilla.`);
      }
      products.push({ handle: decodeURIComponent(match[1]), producto: name, portada_actual: cover });
    }
    return {
      products,
      last: Boolean(doc.querySelector('.last-page')),
      listing: Boolean(doc.querySelector('.js-product-table, [data-store="product-grid"]')),
    };
  }, { html, baseUrl });
}

export function mergeProducts(existing, products) {
  const headers = [...existing.headers];
  for (const header of [...REQUIRED, 'estado']) {
    if (!headers.includes(header)) {
      headers.push(header);
    }
  }
  const rows = new Map(existing.rows.map(row => [row.handle, { ...row, estado: 'no disponible' }]));
  let added = 0;
  for (const product of products) {
    if (!rows.has(product.handle)) {
      added++;
    }
    rows.set(product.handle, { ...rows.get(product.handle), ...product, estado: 'publicado' });
  }
  const sorted = [...rows.values()].sort((a, b) =>
    (a.producto || a.handle).localeCompare(b.producto || b.handle, 'es', { sensitivity: 'base' })
    || a.handle.localeCompare(b.handle)
  );
  return { headers, rows: sorted, added, missing: sorted.filter(row => row.estado === 'no disponible').length };
}

export async function syncProducts({ storeUrl, csvPath = CSV_PATH, delayMs = 750, log = console.log }) {
  const base = new URL(storeUrl);
  if (!['http:', 'https:'].includes(base.protocol)) {
    throw new Error('STORE_URL debe ser la dirección http o https de la tienda.');
  }
  let existing = { headers: [...REQUIRED], rows: [] };
  try {
    existing = await readCSV(csvPath);
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }

  let browser;
  try {
    browser = await chromium.launch({ headless: true });
  } catch {
    throw new Error('Falta el navegador local para leer el catálogo. Ejecutá npm exec playwright install chromium y repetí.');
  }
  const products = new Map();
  try {
    const page = await browser.newPage();
    await page.route('**/*', route => route.abort());
    let finished = false;
    for (let number = 1; number <= 10000; number++) {
      if (number > 1) {
        await pause(delayMs);
      }
      const url = new URL(number === 1 ? '/productos/' : `/productos/page/${number}/?results_only=true`, base);
      log(`Leyendo página ${number} del catálogo público…`);
      const response = await fetch(url, {
        method: 'GET',
        headers: { Accept: 'text/html', 'User-Agent': 'Street-Mocks-Catalog/1.0' },
        signal: AbortSignal.timeout(30000),
      });
      if (!response.ok) {
        throw new Error(`La tienda respondió HTTP ${response.status} en la página ${number}. La planilla quedó intacta.`);
      }
      const finalUrl = new URL(response.url);
      if (!/^\/productos\/(?:page\/\d+\/)?$/.test(finalUrl.pathname)) {
        throw new Error(`La página ${number} redirigió fuera del catálogo. La planilla quedó intacta.`);
      }
      base.host = finalUrl.host;
      base.protocol = finalUrl.protocol;
      const html = await response.text();
      const parsed = await parseProducts(page, html, finalUrl.href);
      if (!parsed.products.length && !parsed.last && !parsed.listing && (number === 1 || html.trim())) {
        throw new Error('No se reconoció el listado de productos. La planilla quedó intacta.');
      }
      let newProducts = 0;
      for (const product of parsed.products) {
        if (!products.has(product.handle)) {
          newProducts++;
        }
        products.set(product.handle, product);
      }
      if (parsed.last || !parsed.products.length) {
        finished = true;
        break;
      }
      if (!newProducts) {
        throw new Error(`La página ${number} repite productos: no se pudo confirmar el catálogo completo. La planilla quedó intacta.`);
      }
    }
    if (!finished) {
      throw new Error('No se encontró el final del catálogo. La planilla quedó intacta.');
    }
  } finally {
    await browser.close();
  }

  const merged = mergeProducts(existing, [...products.values()]);
  await writeAtomic(csvPath, serializeCSV(merged));
  log(`Planilla actualizada: ${products.size} públicos, ${merged.added} nuevos, ${merged.missing} no disponibles. Tus fondos se conservaron.`);
  return merged;
}

if (isMain(import.meta.url)) {
  try {
    try {
      process.loadEnvFile(resolve(ROOT, '.env'));
    } catch (error) {
      if (error.code !== 'ENOENT') {
        throw new Error('No se pudo cargar la configuración local de la tienda.');
      }
    }
    if (!process.env.STORE_URL) {
      throw new Error('Falta STORE_URL en la configuración local. Pedile a quien configuró la tienda que la complete.');
    }
    await syncProducts({ storeUrl: process.env.STORE_URL });
  } catch (error) {
    console.error(`No se actualizó la planilla: ${error.message}`);
    process.exitCode = 1;
  }
}
