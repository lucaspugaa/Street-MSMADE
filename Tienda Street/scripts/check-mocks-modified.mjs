/* global window, document, getComputedStyle */
// Fixtures con la estructura de product-image.tpl / item-slider.tpl; Swiper real del tema.
// Prueba aislada: no lee .env, no accede a Tiendanube ni modifica el producto.
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
const layout = await readFile(new URL('theme/layouts/layout.tpl', root), 'utf8');
const include = /{% if template == 'product' or template == 'category' or template == 'search' %}[\s\S]*?{% endif %}/.exec(layout)[0];
Twig.twig({ id: 'snippets/mocks-modified.tpl', data: snippet });
for (const template of ['product', 'category', 'search', 'home', 'cart']) {
  const html = Twig.twig({ data: include, allowInlineIncludes: true }).render({ template });
  assert.equal(html.includes('data-module="MocksModified"'), ['product', 'category', 'search'].includes(template));
}

const bundle = await build({
  absWorkingDir: fileURLToPath(root), entryPoints: ['src/modules/MocksModified.js'],
  bundle: true, write: false, format: 'iife', globalName: 'MocksModifiedTest',
});
const css = await readFile(new URL('src/styles/modules/mocks-modified.css', root), 'utf8');
const libraries = await readFile(new URL('theme/static/js/libraries-standalone.js', root), 'utf8');
const COVER_SELECTOR = '[data-mocks-modified-cover]';
const handle = 'remera-oversize-red-bull-racing-v7yyp';
const mock = 'https://assets.test/images/mocks/red-bull-1-dorso-oscuro.webp?a=1&b="quoted"';
const image = number => `https://cdn.test/foto-original-${number}.webp`;
const img = number => `<img width="200" height="200" class="product-item-image" src="${image(number)}" srcset="${image(number)} 480w">`;
const gallery = `<section id="single-product"><div class="js-product-images">
<div class="product-images-slider"><div class="js-product-slider swiper-container" data-product-images-amount="2">
<div class="swiper-wrapper">${[1, 2].map((n, i) => `<div class="js-product-slide swiper-slide" data-image="${n}" data-image-position="${i}"><a class="js-product-slide-link" data-fancybox="product-gallery" href="${image(n)}">${img(n)}</a></div>`).join('')}</div>
<button class="js-product-slider-prev">Anterior</button><button class="js-product-slider-next">Siguiente</button></div>
<div class="js-product-slider-pagination">1 / 2</div></div>
<div class="js-product-slider-thumbs swiper-container"><div class="swiper-wrapper">${[1, 2].map((n, i) => `<div class="swiper-slide product-thumb-container"><a class="js-product-thumb ${i === 0 ? 'selected' : ''}" href="#" data-thumb-loop="${i}">${img(n)}</a></div>`).join('')}</div></div>
</div></section>`;
const card = (id, slider = false, productHandle = handle) => `<div id="${id}" class="js-product-item-private product-item" data-product-type="list"><a class="js-product-item-image-link-private" href="/productos/${productHandle}/?variant=2">
${slider ? `<div class="js-product-item-slider-container-private swiper-container" data-images-count="4" data-initial-slides="2" data-max-slides="10" data-append-images='[{"index":3,"thumbs":"${image(3)} 480w"},{"index":4,"thumbs":"${image(4)} 480w"}]'><div class="swiper-wrapper">${[1, 2].map((n, i) => `<div class="js-product-item-slider-slide-private swiper-slide" data-image-position="${i}">${img(n)}</div>`).join('')}</div><button class="js-product-item-prev-container-private">Anterior</button><button class="js-product-item-next-container-private">Siguiente</button><div class="js-product-item-slider-pagination-private">1 / 2</div></div>` : `<picture><source type="image/avif" data-srcset="${image(1)}"><img class="js-product-item-image-private lazyload" width="200" height="200" src="${image(1)}" data-srcset="${image(1)} 480w"></picture><img class="js-product-item-secondary-image-private" src="${image(2)}">`}
</a></div>`;

function fixture(url) {
  const template = url.pathname.startsWith('/productos/') ? 'product' : url.pathname === '/' ? 'home' : url.pathname === '/search/' ? 'search' : 'category';
  const media = url.searchParams.has('one') ? gallery.replace(/<div class="js-product-slide swiper-slide" data-image="2"[\s\S]*?<\/a><\/div>/, '').replace(/<div class="js-product-slider-thumbs[\s\S]*$/, '</div></section>').replace(/<button class="js-product-slider-prev"[\s\S]*?<\/button><button[\s\S]*?<\/button>/, '').replace(/<div class="js-product-slider-pagination">[\s\S]*?<\/div>/, '').replace('data-product-images-amount="2"', 'data-product-images-amount="1"') : gallery;
  return `<!doctype html><style>${css}
.swiper-container{width:200px;overflow:hidden;position:relative}.swiper-wrapper{display:flex;position:relative;box-sizing:content-box}.swiper-slide{flex-shrink:0;width:100%}img{display:block;width:200px;height:200px}.js-product-slider-thumbs img{width:50px;height:50px}
</style><script>window.lazySizesConfig={init:false};</script><script src="/libraries.js"></script>
<body class="template-${template}"><header class="js-header" style="height:80px"></header><main id="MainContent">
${template === 'product' ? media : ''}<section data-store="related-products">${card('single')}${card('slider', true)}${card('unknown', false, 'sin-mock')}</section>
${template === 'home' ? `<section id="best-sellers">${card('bestseller')}</section>` : ''}</main>
<div id="outside">${card('outside-card')}</div>${mount}<script>${bundle.outputFiles[0].text}</script><script>
window.apiCalls={prepend:0,update:0};
window.initSliders=()=>{
 document.querySelectorAll('.swiper-container').forEach(container=>{
  if(container.swiper)return;
  const product=container.matches('.js-product-slider');
  const thumb=container.matches('.js-product-slider-thumbs');
  const instance=new window.Swiper(container,{slidesPerView:thumb?2:1,speed:0,
   pagination:thumb?false:{el:product?document.querySelector('.js-product-slider-pagination'):container.querySelector('.js-product-item-slider-pagination-private'),type:'fraction'},
   navigation:thumb?false:{prevEl:container.querySelector('button:first-of-type'),nextEl:container.querySelector('button:last-of-type')}
  });
  for(const [method,key] of [['prependSlide','prepend'],['update','update']]){
   const original=instance[method].bind(instance);instance[method]=(...args)=>{window.apiCalls[key]++;return original(...args);};
  }
 });
};
document.addEventListener('click',event=>{
 const thumb=event.target.closest('.js-product-thumb');if(!thumb)return;
 event.preventDefault();document.querySelector('.js-product-slider').swiper?.slideTo(Number(thumb.dataset.thumbLoop));
});
if(new URLSearchParams(location.search).get('engine')==='ready')window.initSliders();
window.originalGallery=document.querySelector('.js-product-images')?.innerHTML;
window.originalCard=document.querySelector('#single').innerHTML;
window.originalNodes=[...document.querySelectorAll('.js-product-slide')];
window.originalPicture=document.querySelector('#single picture');
window.module=new MocksModifiedTest.MocksModified(document.querySelector('[data-module]'));
window.refreshes=0;const refresh=window.module.refresh.bind(window.module);
window.module.refresh=()=>{window.refreshes++;refresh();};window.module.init();
</script></body>`;
}

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
      await route.fulfill(url.pathname === '/libraries.js'
        ? { contentType: 'text/javascript', body: libraries }
        : { contentType: 'text/html', body: fixture(url) });
    } else {
      if (url.hostname === 'assets.test') {
        mockRequests++;
      }
      await route.fulfill({ contentType: 'image/png', body: Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==', 'base64') });
    }
  });

  // Sin activación: mismos nodos/HTML, ni observer ni requests de mock.
  for (const path of [`/productos/${handle}/`, '/category/', '/search/']) {
    await page.goto(`http://mocks.test${path}`);
    assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
    assert.equal(await page.locator('.mocks-modified').count(), 0);
    assert.equal(await page.evaluate(() => Boolean(window.module.observer)), false);
    assert.equal(await page.evaluate(() => document.querySelector('#single').innerHTML === window.originalCard), true);
  }
  assert.equal(mockRequests, 0);

  for (const engine of ['ready', 'fallback', 'late']) {
    await page.goto(`http://mocks.test/productos/${handle}/?mocks=oscuro&engine=${engine}`);
    assert.equal(await page.locator('.js-product-slider > .swiper-wrapper > .swiper-slide').count(), 3);
    assert.equal(await page.locator('.js-product-slider-thumbs .swiper-slide').count(), 3);
    assert.equal(await page.locator('.js-product-slider img').first().getAttribute('src'), mock);
    assert.equal(await page.locator('[data-fancybox="product-gallery"]').first().getAttribute('href'), mock);
    assert.deepEqual(await page.locator('.js-product-slide:not([data-mocks-modified-cover]) img').evaluateAll(nodes => nodes.map(img => img.getAttribute('src'))), [image(1), image(2)]);
    assert.deepEqual(await page.locator('.js-product-thumb').evaluateAll(nodes => nodes.map(thumb => thumb.dataset.thumbLoop)), ['0', '1', '2']);
    assert.equal(await page.locator('.js-product-slider').getAttribute('data-product-images-amount'), '3');
    assert.equal(await page.locator('#slider .swiper-slide').count(), 3);
    assert.equal(await page.locator('#slider img').first().getAttribute('src'), mock);
    assert.equal(await page.locator('#slider .swiper-container').getAttribute('data-images-count'), '5');
    assert.equal(await page.locator('#single [data-mocks-modified-cover]').getAttribute('src'), mock);
    assert.equal(await page.locator('#unknown picture').count(), 1);
    assert.equal(await page.locator('#outside-card picture').count(), 1);
    assert.equal(await page.locator('#single .js-product-item-secondary-image-private').getAttribute('src'), image(2));

    if (engine === 'ready') {
      assert.equal(await page.evaluate(() => window.apiCalls.prepend), 3);
    }
    if (engine === 'late') {
      await page.evaluate(() => window.initSliders());
      await page.waitForFunction(() => document.querySelectorAll('.mocks-modified-fallback').length === 0);
    }

    await page.locator('.js-product-slider-next').click();
    await page.waitForFunction(() => document.querySelector('.js-product-slider-pagination').textContent.replace(/\s/g, '') === '2/3');
    await page.locator('.js-product-thumb').nth(2).click();
    await page.waitForFunction(() => document.querySelector('.js-product-slider-pagination').textContent.replace(/\s/g, '') === '3/3');
    await page.locator('#slider .js-product-item-next-container-private').click();
    await page.waitForFunction(() => document.querySelector('#slider .js-product-item-slider-pagination-private').textContent.replace(/\s/g, '') === '2/3');

    // Lazy/infinite scroll: nuevas tarjetas y nuevas fotos permanecen en orden.
    await page.evaluate(html => document.querySelector('[data-store="related-products"]').insertAdjacentHTML('beforeend', html), card('late-card'));
    await page.waitForFunction(() => document.querySelector('#late-card [data-mocks-modified-cover]'));
    await page.locator('#single [data-mocks-modified-cover]').evaluate(img => img.setAttribute('srcset', 'https://cdn.test/lazy.webp 480w'));
    await page.waitForFunction(() => !document.querySelector('#single [data-mocks-modified-cover]').hasAttribute('srcset'));
    const alternate = 'https://assets.test/alternate.webp';
    await page.evaluate(({ handle, alternate }) => {
      window.module.config.products[handle].claro = alternate;
      window.module.config.labels.claro = 'Fondo claro';
      window.module.refresh();
    }, { handle, alternate });
    await page.getByRole('button', { name: 'Fondo claro' }).click();
    assert.equal(await page.locator('.js-product-slider img').first().getAttribute('src'), alternate);
    assert.equal(await page.locator('.js-product-slider .swiper-slide').count(), 3);
    assert.equal(await page.locator('#single [data-mocks-modified-cover]').getAttribute('src'), alternate);

    const bounds = await page.locator('.mocks-modified').boundingBox();
    const headerBottom = await page.locator('.js-header').evaluate(header => header.getBoundingClientRect().bottom);
    assert.ok(bounds.x >= 0 && bounds.x + bounds.width <= 390 && bounds.y >= Math.max(8, headerBottom + 8));
    await page.setViewportSize({ width: 1440, height: 900 });
    const desktopBounds = await page.locator('.mocks-modified').boundingBox();
    assert.ok(desktopBounds.x >= 0 && desktopBounds.x + desktopBounds.width <= 1440);
    await page.setViewportSize({ width: 390, height: 844 });
    await page.keyboard.press('Tab');
    await page.getByRole('button', { name: 'Original' }).focus();
    assert.equal(await page.getByRole('button', { name: 'Original' }).evaluate(button => getComputedStyle(button).outlineStyle), 'solid');
    await page.getByRole('button', { name: 'Original' }).click();
    assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
    assert.equal(await page.locator('.js-product-slider .swiper-slide').count(), 2);
    assert.equal(await page.locator('.js-product-slider-thumbs .swiper-slide').count(), 2);
    assert.deepEqual(await page.locator('.js-product-thumb').evaluateAll(nodes => nodes.map(thumb => thumb.dataset.thumbLoop)), ['0', '1']);
    assert.equal(await page.locator('.js-product-slider').getAttribute('data-product-images-amount'), '2');
    assert.equal(await page.locator('#slider .swiper-container').getAttribute('data-images-count'), '4');
    assert.equal(await page.evaluate(() => document.querySelector('#single picture') === window.originalPicture), true);
    assert.equal(await page.evaluate(() => window.originalNodes.every(node => node.isConnected)), true);
    assert.equal(await page.evaluate(() => document.querySelector('#single').innerHTML === window.originalCard), true);
    if (engine === 'fallback') {
      assert.equal(await page.evaluate(() => document.querySelector('.js-product-images').innerHTML === window.originalGallery), true);
    }
    if (engine !== 'fallback') {
      await page.locator('.js-product-slider-next').click();
      await page.waitForFunction(() => document.querySelector('.js-product-slider-pagination').textContent.replace(/\s/g, '') === '2/2');
    }
    assert.ok(await page.evaluate(() => window.refreshes < 40));
  }

  for (const engine of ['ready', 'fallback']) {
    await page.goto(`http://mocks.test/productos/${handle}/?mocks=oscuro&engine=${engine}&one=1`);
    assert.equal(await page.locator('.js-product-slider .swiper-slide').count(), 2);
    assert.equal(await page.locator('.js-product-slider-thumbs').count(), 0);
    await page.getByRole('button', { name: 'Imagen siguiente' }).click();
    await page.waitForFunction(() => document.querySelector('[data-mocks-modified-owned]:not(.mocks-modified-navigation)').textContent === '2 / 2');
    await page.getByRole('button', { name: 'Original' }).click();
    assert.equal(await page.locator('[data-mocks-modified-owned]').count(), 0);
    assert.equal(await page.locator('.js-product-slider .swiper-slide').count(), 1);
  }

  for (const path of ['/category/', '/search/']) {
    await page.goto(`http://mocks.test${path}?mocks=1&engine=ready`);
    assert.equal(await page.locator('#single [data-mocks-modified-cover]').getAttribute('src'), mock);
    await page.getByRole('button', { name: 'Original' }).click();
    assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
  }

  await page.goto('http://mocks.test/?mocks=oscuro');
  assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
  assert.equal(await page.locator('#bestseller picture').count(), 1);
  await page.goto('http://mocks.test/category/');
  assert.equal(await page.locator('#single [data-mocks-modified-cover]').getAttribute('src'), mock);
  await page.goto('http://mocks.test/search/?mocks=0');
  assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
  assert.equal(await page.evaluate(() => sessionStorage.getItem('street-mocks-modified')), null);
  await page.goto('http://mocks.test/category/');
  assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
  await page.addInitScript(() => {
    Object.defineProperty(window, 'sessionStorage', { get() { throw new Error('blocked'); } });
  });
  await page.goto('http://mocks.test/category/?mocks=oscuro');
  assert.equal(await page.locator('#single [data-mocks-modified-cover]').getAttribute('src'), mock);
  await page.evaluate(() => window.module.destroy());
  assert.equal(await page.locator(COVER_SELECTOR).count(), 0);
  assert.deepEqual(errors, []);
  console.log('OK MocksModified: handle/Twig, opt-in, ficha/zoom/miniaturas, tarjetas/lazy, Swiper real/fallback/tardío, Original exacto, home intacta, sesión/off/storage y 390px.');
} finally {
  await browser.close();
}
