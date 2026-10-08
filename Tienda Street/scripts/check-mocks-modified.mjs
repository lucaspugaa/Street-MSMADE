/* global window, document, getComputedStyle */
// Prueba local aislada: no lee .env ni accede a Tiendanube.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';
import { chromium } from 'playwright';
import Twig from 'twig';

const root = new URL('../', import.meta.url);
const snippet = await readFile(new URL('theme/snippets/mocks-modified.tpl', root), 'utf8');
Twig.extendFilter('static_url', value => `https://assets.test/${value}?a=1&b="quoted"`);
const mount = Twig.twig({ data: snippet, rethrow: true }).render({});
const bundle = await build({
  absWorkingDir: fileURLToPath(root),
  entryPoints: ['src/modules/MocksModified.js'],
  bundle: true,
  write: false,
  format: 'iife',
  globalName: 'MocksModifiedTest',
});
const css = await readFile(new URL('src/styles/modules/mocks-modified.css', root), 'utf8');
const hash = '49169969438efd006c17752525592384';
const image = size => `https://cdn.test/products/red-bull-1-dorso-${hash}-${size}-0.webp`;
const unknown = `https://cdn.test/products/otra-imagen-${hash}-480-0.webp`;
const mock = 'https://assets.test/images/mocks/red-bull-1-dorso-oscuro.webp?a=1&b="quoted"';
const fixture = `<!doctype html><style>${css}</style>
<header class="js-header" style="height:80px"></header>
<section id="single-product"><div class="js-product-images">
<a id="zoom" href="${image(3840)}"><img id="main" src="${image(480)}" srcset="${image(480)} 480w, ${image(1024)} 1024w"></a>
<img id="lazy" src="data:image/gif;base64,R0lGODlhAQABAAAAACw=" data-srcset="${image(100)} 100w, ${image(240)} 240w">
<img id="lazy-src" src="data:image/gif;base64,R0lGODlhAQABAAAAACw=" data-src="${image(480)}">
<picture><source id="source" type="image/avif" data-srcset="${image(480)} 480w"></picture>
<img id="unknown" src="${unknown}"></div></section>
<div id="related"><img src="${image(480)}"></div>${mount}
<script>${bundle.outputFiles[0].text}</script>
<script>window.module = new MocksModifiedTest.MocksModified(document.querySelector('[data-module]'));
window.module.init();</script>`;

const browser = await chromium.launch({ headless: true });
try {
  const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
  const page = await context.newPage();
  const errors = [];
  let mockRequests = 0;
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', async route => {
    const url = new URL(route.request().url());
    if (url.hostname === 'mocks.test') {
      await route.fulfill({ contentType: 'text/html', body: url.pathname === '/no-mock/' ? fixture.replaceAll('/products/red-bull-1-dorso', '/products/sin-mock') : fixture });
    } else {
      if (url.hostname === 'assets.test') {
        mockRequests++;
      }
      await route.fulfill({ status: 200, contentType: 'image/webp', body: Buffer.alloc(0) });
    }
  });

  await page.goto('http://mocks.test/product/');
  assert.equal(await page.locator('.mocks-modified').count(), 0);
  assert.equal(await page.locator('[data-mocks-modified-original]').count(), 0);
  assert.equal(await page.evaluate(() => Boolean(window.module.observer)), false);
  assert.equal(mockRequests, 0);
  assert.equal(await page.locator('#main').getAttribute('src'), image(480));

  await page.goto('http://mocks.test/product/?mocks=oscuro');
  assert.equal(await page.locator('#main').getAttribute('src'), mock);
  assert.equal(await page.locator('#main').getAttribute('srcset'), mock);
  assert.equal(await page.locator('#zoom').getAttribute('href'), mock);
  assert.equal(await page.locator('#lazy').getAttribute('data-srcset'), mock);
  assert.equal(await page.locator('#source').getAttribute('type'), 'image/webp');
  assert.equal(await page.locator('#unknown').getAttribute('src'), unknown);
  assert.equal(await page.locator('#related img').getAttribute('src'), image(480));
  assert.equal(await page.getByRole('button', { name: 'Fondo oscuro' }).getAttribute('aria-pressed'), 'true');
  const bounds = await page.locator('.mocks-modified').boundingBox();
  assert.ok(bounds.x >= 0 && bounds.x + bounds.width <= 390 && bounds.y >= 88);
  await page.setViewportSize({ width: 1440, height: 900 });
  const desktopBounds = await page.locator('.mocks-modified').boundingBox();
  assert.ok(desktopBounds.x + desktopBounds.width <= 1440 && desktopBounds.y >= 88);
  await page.setViewportSize({ width: 390, height: 844 });
  await page.getByRole('button', { name: 'Original' }).focus();
  assert.equal(await page.getByRole('button', { name: 'Original' }).evaluate(button => getComputedStyle(button).outlineStyle), 'solid');

  await page.evaluate(({ original, replacement }) => {
    const img = document.createElement('img');
    img.id = 'late';
    img.setAttribute('src', original);
    document.querySelector('.js-product-images').append(img);
    document.querySelector('#lazy').setAttribute('srcset', replacement);
    document.querySelector('#lazy-src').setAttribute('src', replacement);
  }, { original: image(640), replacement: mock });
  await page.waitForFunction(replacement => document.querySelector('#late').getAttribute('src') === replacement, mock);
  await page.locator('#main').evaluate((img, original) => img.setAttribute('src', original), image(1024));
  await page.waitForFunction(replacement => document.querySelector('#main').getAttribute('src') === replacement, mock);

  const alternate = 'https://assets.test/alternate.webp';
  await page.evaluate(replacement => {
    window.module.config.images['red-bull-1-dorso'].claro = replacement;
    window.module.config.labels.claro = 'Fondo claro';
    window.module.refresh();
  }, alternate);
  await page.getByRole('button', { name: 'Fondo claro' }).click();
  assert.equal(await page.locator('#lazy-src').getAttribute('src'), alternate);
  assert.equal(await page.locator('#lazy').getAttribute('srcset'), alternate);
  assert.equal(await page.locator('#main').getAttribute('src'), alternate);
  await page.getByRole('button', { name: 'Original' }).click();
  assert.equal(await page.locator('#main').getAttribute('src'), image(480));
  assert.equal(await page.locator('#zoom').getAttribute('href'), image(3840));
  assert.equal(await page.locator('#late').getAttribute('src'), image(640));
  assert.equal(await page.locator('#lazy').getAttribute('srcset'), `${image(100)} 100w, ${image(240)} 240w`);
  assert.equal(await page.locator('#lazy-src').getAttribute('src'), image(480));
  assert.equal(await page.locator('#source').getAttribute('type'), 'image/avif');
  assert.equal(await page.locator('[data-mocks-modified-original]').count(), 0);

  await page.goto('http://mocks.test/product/');
  assert.equal(await page.getByRole('button', { name: 'Original' }).getAttribute('aria-pressed'), 'true');
  await page.getByRole('button', { name: 'Fondo oscuro' }).click();
  await page.goto('http://mocks.test/product/');
  assert.equal(await page.locator('#main').getAttribute('src'), mock);
  await page.goto('http://mocks.test/no-mock/');
  assert.equal(await page.locator('.mocks-modified').count(), 0);
  assert.equal(await page.locator('[data-mocks-modified-original]').count(), 0);

  await page.goto('http://mocks.test/product/?mocks=0');
  assert.equal(await page.locator('.mocks-modified').count(), 0);
  assert.equal(await page.evaluate(() => sessionStorage.getItem('street-mocks-modified')), null);
  await page.goto('http://mocks.test/product/');
  assert.equal(await page.locator('.mocks-modified').count(), 0);
  await page.goto('http://mocks.test/product/?mocks=1');
  assert.equal(await page.locator('#main').getAttribute('src'), mock);
  await page.evaluate(() => window.module.destroy());
  assert.equal(await page.locator('#main').getAttribute('src'), image(480));
  assert.equal(await page.locator('.mocks-modified').count(), 0);

  await page.addInitScript(() => {
    Object.defineProperty(window, 'sessionStorage', { get() { throw new Error('blocked'); } });
  });
  await page.goto('http://mocks.test/product/?mocks=oscuro');
  assert.equal(await page.locator('#main').getAttribute('src'), mock);
  await page.goto('http://mocks.test/product/?mocks=0');
  assert.equal(await page.locator('.mocks-modified').count(), 0);
  assert.deepEqual(errors, []);
  console.log('OK MocksModified: Twig/escape, opt-in sin red, sesión/off, Original, lazy/inserciones, aislamiento, 390px/foco y storage bloqueado.');
} finally {
  await browser.close();
}
