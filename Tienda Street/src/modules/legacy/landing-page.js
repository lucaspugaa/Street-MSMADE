// Copia fiel del <script> del bloque de código original (home · code_twch).
// Se ejecuta tal cual desde su módulo; el refactor a clases queda para cuando haya preview para verificar.
export function run() {
(function () {
'use strict';

const main = document.getElementById('MainContent');
const parent = document.querySelector('.parent-universes');
const storeOrigin = location.href === 'about:srcdoc' ? 'https://street1640shop.mitiendanube.com' : location.origin;
const isTest = location.href === 'about:srcdoc'
|| new URLSearchParams(location.search).get('preview_theme_installation_id') === '14559883';

if (!main || !parent) {
return;
}

const universes = {
"kumo": {
"name": "KUMØ",
"path": "/anime/",
"label": "KUMØ / 雲",
"hash": "kumo-preview",
"ribbon": [
"ONE PIECE",
"DRAGON BALL",
"NARUTO"
],
"variants": [
[
"KUMØ Original",
"kumo-reference",
"#0b1020",
"#c8a56a",
"#cbbc99",
"KUMØ",
"",
"KUMØ / 雲"
],
[
"KUMØ Updated",
"kumo-updated",
"#0b1020",
"#c8a56a",
"#cbbc99",
"KUMØ",
"Anime para llevar con vos.",
"KUMØ / 雲"
],
[
"KUMØ Cyberpunk",
"kumo-cyberpunk",
"#050607",
"#e5eeed",
"#64f5e7",
"KUMØ",
"Tu universo, después de medianoche.",
"ANIME / 雲"
]
]
},
"football": {
"name": "90",
"path": "/futbol-noventa/",
"label": "90 MINUTOS Fútbol / Edición archivo",
"hash": "football-preview",
"ribbon": [
"SELECCIÓN ARGENTINA",
"ÍDOLOS",
"ARCHIVO 90 MINUTOS"
],
"variants": [
[
"Tapa 90",
"football-cover",
"#fff6d7",
"#161616",
"#e62d20",
"90",
"",
"90 MINUTOS FÚTBOL / EDICIÓN 01"
],
[
"Don Fútbol",
"football-teal",
"#087480",
"#fff5cb",
"#ffdf2a",
"90 MINUTOS FÚTBOL",
"",
"ARCHIVO / ARGENTINA / SELECCIÓN"
],
[
"El Suplemento",
"football-paper",
"#fff0c9",
"#072f72",
"#f02d2a",
"EL SUPLEMENTO",
"",
"90 / FÚTBOL ARGENTINO"
],
[
"El Póster",
"football-poster",
"#f1db38",
"#10276a",
"#ec2e24",
"FÚTBOL 90 MINUTOS",
"",
"SELECCIÓN / RETRO / ARGENTINA"
],
[
"Figuritas",
"football-stickers",
"#174db2",
"#fff6d6",
"#ed4d1c",
"90 CLUB",
"",
"ÁLBUM / 90 MINUTOS FÚTBOL"
]
]
},
"bts": {
"name": "BTS / ARIRANG",
"path": "/artistas1/bts/",
"label": "BTS World Tour · ARIRANG",
"hash": "bts-preview",
"ribbon": [
"BTS",
"ARIRANG",
"WORLD TOUR / 2026"
],
"variants": [
[
"Tour Rojo",
"bts-red",
"#ba181e",
"#fff5e8",
"#191919",
"ARIRANG",
"",
"BTS / WORLD TOUR"
],
[
"Army Night",
"bts-night",
"#10101d",
"#faf4ff",
"#c5a0ff",
"BTS / ARIRANG",
"",
"ARGENTINA / 2026"
],
[
"Entrada",
"bts-ticket",
"#f2ecdf",
"#201e1b",
"#bd2326",
"ARIRANG",
"",
"BTS WORLD TOUR / ARGENTINA"
],
[
"Purple Room",
"bts-purple",
"#d6c2f2",
"#332252",
"#faf7f0",
"BTS",
"",
"ARIRANG / WORLD TOUR"
],
[
"Setlist",
"bts-setlist",
"#fcf4e5",
"#252321",
"#ad202b",
"ARIRANG / 2026",
"",
"BTS / ARGENTINA"
]
]
},
"artistas": {
"name": "ARTISTAS",
"path": "/artistas1/",
"label": "ARTISTAS",
"hash": "artistas-preview",
"ribbon": [
"ARTISTAS",
"BTS / ARIRANG",
"STREET 1640"
],
"variants": [
[
"Doble Cara",
"artists-split",
"#151515",
"#fff4e2",
"#e66936",
"ARTISTAS",
"",
"ARTISTAS / COLLECTION"
],
[
"Disquería",
"artists-record",
"#f2e5c9",
"#211e1b",
"#256b58",
"ARTISTAS",
"",
"ARTISTAS / STREET 1640"
],
[
"Flyers",
"artists-flyers",
"#eade30",
"#17203a",
"#df37a3",
"ARTISTAS",
"",
"ARTISTAS / STREET 1640"
],
[
"Sesiones",
"artists-sessions",
"#ece8e1",
"#202320",
"#293f8e",
"ARTISTAS / 01",
"",
"OASIS · AIRBAG / BAD BUNNY · DUKI"
],
[
"Pared de Afiches",
"artists-wall",
"#1b213a",
"#f4eee0",
"#f05635",
"ARTISTAS",
"",
"ARTISTAS / STREET 1640"
],
[
"Lanzamiento Rojo",
"artists-launch-red",
"#ba181e",
"#fff5e8",
"#191919",
"ARIRANG",
"",
"BTS / WORLD TOUR"
],
[
"Edición ARIRANG",
"artists-launch-paper",
"#f2ecdf",
"#241915",
"#bd2326",
"ARTISTAS",
"",
"LANZAMIENTO / BTS · ARIRANG"
],
[
"Army Night",
"artists-launch-night",
"#10101d",
"#faf4ff",
"#c5a0ff",
"ARTISTAS",
"",
"LANZAMIENTO / BTS · ARIRANG"
],
[
"Cartelera",
"artists-launch-posters",
"#f4efe5",
"#191919",
"#bd2326",
"ARTISTAS",
"",
"LANZAMIENTO / BTS · ARIRANG"
],
[
"Backstage",
"artists-launch-gallery",
"#dedbd3",
"#222222",
"#ae2728",
"ARTISTAS",
"",
"LANZAMIENTO / BTS · ARIRANG"
]
]
},
"f1": {
"name": "F1",
"path": "/formula-12/",
"label": "F1 / MOTORSPORT",
"hash": "f1-preview",
"ribbon": [
"COLAPINTO",
"FERRARI",
"MCLAREN",
"RED BULL"
],
"variants": [
[
"Pit Lane",
"f1-pit",
"#101114",
"#f0eee8",
"#ef3025",
"F1",
"",
"MOTORSPORT / PIT LANE"
],
[
"Paddock",
"f1-paddock",
"#f2efe5",
"#191919",
"#df2d21",
"PADDOCK",
"",
"F1 / EDICIÓN 02"
],
[
"Telemetry",
"f1-telemetry",
"#081d18",
"#d3f2da",
"#a9e92f",
"TELEMETRY",
"",
"F1 / SECTOR 03"
],
[
"Grid",
"f1-grid",
"#f6eecc",
"#101a38",
"#1649d6",
"THE GRID",
"",
"F1 / EDICIÓN 04"
],
[
"Monochrome",
"f1-mono",
"#e6e6e3",
"#181818",
"#555555",
"F1 / ARCHIVE",
"",
"MOTORSPORT / 05"
]
]
}
};

const navigation = [
{
"name": "FORMULA 1",
"path": "/formula-12/"
},
{
"name": "Ver Todo",
"path": "/formula-12/ver-todo/"
},
{
"name": "Escuderias",
"path": "/formula-12/escuderias/"
},
{
"name": "Pilotos",
"path": "/formula-12/historicos/"
},
{
"name": "Diseños",
"path": "/formula-12/disenos/"
},
{
"name": "ARTISTAS",
"path": "/artistas1/"
},
{
"name": "Ver Todo",
"path": "/artistas1/ver-todo1/"
},
{
"name": "Bad Bunny",
"path": "/artistas1/bad-bunny/"
},
{
"name": "Oasis",
"path": "/artistas1/oasis/"
},
{
"name": "Duki",
"path": "/artistas1/duki/"
},
{
"name": "Trueno",
"path": "/artistas1/trueno/"
},
{
"name": "ELADIO CARRION",
"path": "/artistas1/eladio-carrion/"
},
{
"name": "SABRINA CARPENTER",
"path": "/artistas1/sabrina-carpenter/"
},
{
"name": "TINI",
"path": "/artistas1/tini/"
},
{
"name": "OMAR COURTZ",
"path": "/artistas1/omar-courtz/"
},
{
"name": "BTS",
"path": "/artistas1/bts/"
},
{
"name": "ANIME × KUMØ",
"path": "/anime/"
},
{
"name": "Ver Todo",
"path": "/anime/ver-todo3/"
},
{
"name": "One Piece",
"path": "/anime/one-piece/"
},
{
"name": "Demon Slayer",
"path": "/anime/demon-slayer/"
},
{
"name": "Dragon Ball",
"path": "/anime/dragon-ball/"
},
{
"name": "Attack On Titan",
"path": "/anime/attack-on-titan/"
},
{
"name": "Naruto",
"path": "/anime/naruto/"
},
{
"name": "Jujutsu Kaisen",
"path": "/anime/jujutsu-kaisen/"
},
{
"name": "FÚTBOL × 90",
"path": "/futbol-noventa/"
},
{
"name": "Ver Todo",
"path": "/futbol-noventa/ver-todo2/"
},
{
"name": "Idolos",
"path": "/futbol-noventa/idolos/"
},
{
"name": "Argentina",
"path": "/futbol-noventa/argentina/"
},
{
"name": "Red Bull",
"path": "/formula-12/escuderias/red-bull/"
},
{
"name": "Ferrari",
"path": "/formula-12/escuderias/ferrari/"
},
{
"name": "McLaren",
"path": "/formula-12/escuderias/mclaren/"
},
{
"name": "Mercedez",
"path": "/formula-12/escuderias/mercedez/"
},
{
"name": "Alpine",
"path": "/formula-12/escuderias/alpine/"
}
];
const catalogCache = new Map();
const editorialAssets = {
"kumo": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp",
"kumoUpdated": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/0f6660a9-kumo-updated-lossless/source.webp",
"kumoCyberpunk": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/4fe67ff1-kumo-cyberpunk-2026-10-04/source.png",
"f1Hero": [
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/39487a03-codex-clipboard-de232fc7-61fb-4cfd-9335-fa12de97dfd2/source.jpg",
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/42178290-codex-clipboard-365b3c64-aaa3-440b-97f8-8c0f8dc67bf6/source.jpg",
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/dd5882b0-codex-clipboard-77a4e28f-4d8e-4e7c-aebe-7a8b21175b35/source.jpg"
],
"footballHero": [
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/ff58313a-codex-clipboard-4c1844b7-15a2-4eac-b7b5-57b9392cb821/source.jpg",
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/8377a35f-codex-clipboard-5982906c-d4dd-4717-beb7-7dca81a33baf/source.jpg",
"https://acdn-us.mitiendanube.com/stores/004/626/860/media/86748153-codex-clipboard-68886594-3eac-4de6-a734-e23802f38b9e/source.jpg"
],
"artistasTourProducts": [
{
"name": "Remera BTS - 2.0",
"image": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-artistas-frente-b1171d1da2ff30342f17874347053002-480-0.webp"
},
{
"name": "Remera BTS - 2.0 Black",
"image": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-2-0-negrodorso-9cc59272b32d0b8aac17874366236354-480-0.webp"
},
{
"name": "Remera BTS - Cupid",
"image": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-angel-crema-dorso-fbf4d279c60326177317874346167757-480-0.webp"
}
],
"kumoSrcset": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/d9af73a8-kumo-480/source.webp 480w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/f31f98f0-kumo-960/source.webp 960w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp 1672w",
"kumoUpdatedSrcset": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/7263f99e-kumo-updated-960/source.webp 960w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/0f6660a9-kumo-updated-lossless/source.webp 1672w"
}
;
const countdownConfig = {
"target": "2026-10-21T00:00:00-03:00",
"label": "21 OCT 2026 / ARGENTINA · CUENTA HASTA EL DÍA DEL SHOW",
"source": "https://btsworldtourofficial.com/",
"confirmed": true
}
;
const selections = { kumo: 1, football: 1, artistas: 5, bts: 0, f1: 0 };
const money = new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' });
let view = null;
let current = null;
let activeProducts = [];
let loadSequence = 0;
let countdownTimer = null;

function updatePreviewUrl(key) {
if (location.href === 'about:srcdoc') {
return;
}

const url = new URL(location.href);
url.searchParams.set('propuesta', String(selections[key] + 1));
url.hash = universes[key].hash;
history.replaceState(null, '', url);
}

function element(tag, className, text) {
const node = document.createElement(tag);
if (className) {
node.className = className;
}
if (text !== undefined) {
node.textContent = text;
}
return node;
}

function previewUrl(path) {
const url = new URL(path, storeOrigin);
if (isTest) { url.searchParams.set('preview_theme_installation_id', '14559883'); } else { url.searchParams.delete('preview_theme_installation_id'); }
return url.href;
}

function parseProducts(html, path) {
const parsed = new DOMParser().parseFromString(html, 'text/html');
const products = [];

parsed.querySelectorAll('.js-product-table [data-product-id]').forEach(card => {
const schema = card.querySelector('script[type="application/ld+json"]');
if (!schema) {
return;
}

const data = JSON.parse(schema.textContent);
const offer = Array.isArray(data.offers) ? data.offers[0] : data.offers;
const image = Array.isArray(data.image) ? data.image[0] : data.image;
const href = offer?.url || data.mainEntityOfPage?.['@id'];

if (!data.name || !image || !href) {
return;
}

products.push({
id: card.dataset.productId,
name: data.name,
image: new URL(image, storeOrigin).href,
alternateImage: oppositeColorImage(card, image),
promotion: card.querySelector('[data-promotion-type="quantity-discounts"]')?.textContent.trim().replace(/\s+/g, ' ') || '',
url: previewUrl(href),
price: offer?.price === undefined ? null : Number(offer.price),
available: !String(offer?.availability).includes('OutOfStock')
});
});

const totalMatch = html.match(/LS\.productsCount\s*=\s*(\d+)/);
const total = totalMatch ? Number(totalMatch[1]) : products.length;
const root = new URL(path, storeOrigin);
const categories = new Map();

parsed.querySelectorAll('#ns-section-product_list a[href]').forEach(link => {
const url = new URL(link.getAttribute('href'), storeOrigin);
const label = link.textContent.trim();
if (url.origin === root.origin && url.pathname.startsWith(root.pathname)
&& url.pathname !== root.pathname && label && label.length < 60) {
categories.set(url.pathname, { path: url.pathname, label });
}
});

return { products, total, categories: [...categories.values()] };
}

const catalogPageCache = new Map();

function getCatalogPage(path) {
const url = new URL(previewUrl(path));
if (!url.searchParams.has('sort_by')) {
url.searchParams.set('sort_by', 'best-selling');
}
if (url.searchParams.get('page') === '1') {
url.searchParams.delete('page');
}
url.searchParams.sort();
const key = url.href;

if (catalogPageCache.has(key)) {
return catalogPageCache.get(key);
}

const task = (async () => {
const response = await fetch(key, { credentials: 'same-origin' });
if (!response.ok) {
throw new Error('El catálogo no respondió.');
}

return parseProducts(await response.text(), url.pathname);
})();

catalogPageCache.set(key, task);
task.catch(() => catalogPageCache.delete(key));
return task;
}

async function getCatalog(path, onProgress) {
const ordered = new URL(path, storeOrigin);
if (!ordered.searchParams.has('sort_by')) {
ordered.searchParams.set('sort_by', 'best-selling');
}
ordered.searchParams.sort();
path = ordered.pathname + ordered.search;

if (catalogCache.has(path)) {
return catalogCache.get(path);
}

const task = (async () => {
const first = await getCatalogPage(path);
const products = new Map(first.products.map(product => [product.id, product]));
const pageSize = first.products.length;
const pages = pageSize ? Math.ceil(first.total / pageSize) : 1;

const snapshot = () => ({
products: [...products.values()],
total: first.total,
categories: first.categories
});

if (pages > 1 && onProgress) {
onProgress(snapshot());
}

for (let page = 2; page <= pages; page += 2) {
const paths = [page, page + 1].filter(number => number <= pages).map(number => {
const url = new URL(path, storeOrigin);
url.searchParams.set('page', String(number));
return url.href;
});
const batch = await Promise.all(paths.map(getCatalogPage));

batch.forEach(result => {
result.products.forEach(product => products.set(product.id, product));
});

if (page + 1 < pages && onProgress) {
onProgress(snapshot());
}
}

if (products.size < first.total) {
throw new Error('Faltan productos por cargar: ' + products.size + ' de ' + first.total);
}

return snapshot();
})();

catalogCache.set(path, task);
try {
return await task;
} catch (error) {
catalogCache.delete(path);
throw error;
}
}

function closePreview() {
loadSequence++;
clearInterval(countdownTimer);
const key = current;
view?.remove();
view = null;
current = null;
updateRewards();
main.removeAttribute('data-universe-preview');
const entry = key === 'bts'
? document.querySelector('.portal-bts')
: parent.querySelector(`[data-universe="${key}"]`);
entry?.scrollIntoView({ block: 'center', behavior: 'auto' });
entry?.focus({ preventScroll: true });
if (location.href !== 'about:srcdoc') {
const url = new URL(location.href);
url.searchParams.delete('propuesta');
url.searchParams.delete('coleccion');
url.hash = '';
history.replaceState(null, '', url);
}
}

function productCard(product, catalogUniverse = current) {
const link = element('a', 'universe-product');
link.href = product.url;
if (catalogUniverse) {
const destination = new URL(product.url, storeOrigin);
if (isTest) { destination.searchParams.set('preview_theme_installation_id', '14559883'); } else { destination.searchParams.delete('preview_theme_installation_id'); }
destination.searchParams.set('test_universe', catalogUniverse);
destination.searchParams.set('test_variant', String(selections[catalogUniverse] + 1));
destination.searchParams.set('landing', new URLSearchParams(location.search).get('landing') || '6');
link.href = destination.href;
}
link.addEventListener('click', () => {
const key = current || link.closest('[data-catalog-universe]')?.dataset.catalogUniverse;
if (!key) {
return;
}
const url = new URL(product.url, storeOrigin);
if (isTest) { url.searchParams.set('preview_theme_installation_id', '14559883'); } else { url.searchParams.delete('preview_theme_installation_id'); }
url.searchParams.set('test_universe', key);
url.searchParams.set('test_variant', String(selections[key] + 1));
url.searchParams.set('landing', new URLSearchParams(location.search).get('landing') || '6');
link.href = url.href;
});
link.dataset.productId = product.id;
const visual = element('div', 'product-visual');
const image = element('img');
image.src = product.image;
image.alt = product.name;
image.loading = 'lazy';
image.decoding = 'async';
image.width = 480;
image.height = 600;
visual.append(image);
if (current === 'kumo' && product.alternateImage) {
const alternate = element('img', 'product-alternate');
alternate.src = product.alternateImage;
alternate.alt = product.name + ' · otro color';
alternate.loading = 'lazy';
alternate.width = 480;
alternate.height = 600;
visual.append(alternate);
link.classList.add('has-color-alternate');
}

if (!product.available) {
visual.append(element('span', 'product-stock', 'Sin stock'));
}
if (current === 'kumo' && product.promotion) {
visual.append(element('span', 'kumo-promotion', product.promotion));
}

link.append(visual, element('h3', '', product.name));
link.append(element('span', 'product-price', product.price === null ? 'Consultar precio' : money.format(product.price)));
link.append(element('span', 'product-discover', current === 'kumo' ? 'COMPRAR' : 'VER PRODUCTO ↗'));
return link;
}

function oppositeColorImage(card, primary) {
const images = [...card.querySelectorAll('img')].map(image => {
const sources = (image.getAttribute('data-srcset') || image.getAttribute('srcset') || '').split(',');
const source = sources.find(item => item.trim().endsWith('480w')) || sources[0];
return source ? new URL(source.trim().split(' ')[0], storeOrigin).href : '';
});
const black = /negro|black/i.test(primary);
const opposite = black ? /crema|blanc[oa]|cream|white/i : /negro|black/i;
const face = /dorso|espalda|back/i.test(primary) ? /dorso|espalda|back/i
: /frente|front/i.test(primary) ? /frente|front/i : null;
const candidates = images.filter(image => opposite.test(image));
return (face ? candidates.find(image => face.test(image)) : candidates[0]) || null;
}

function renderLaunchProducts() {
if (current !== 'artistas' || selections.artistas < 5) {
return;
}
let launch = view.querySelector('.artist-bts-launch');
if (!launch) {
launch = element('section', 'artist-bts-launch');
launch.innerHTML = '<div class="artist-launch-heading"><div><p>LANZAMIENTO / BTS</p><h2>ARIRANG</h2><p>ARGENTINA · 21 OCT 2026</p></div><button type="button" class="artist-launch-independent">Comparar tienda BTS ↗</button></div><div class="artist-launch-grid"></div><button type="button" class="artist-launch-all">VER TODAS LAS PRENDAS BTS ↗</button>';
(view.querySelector('.bts-countdown') || view.querySelector('.universe-hero')).after(launch);
launch.querySelector('.artist-launch-independent').remove();
launch.querySelector('.artist-launch-all').onclick = () => {
view.querySelector('.catalog-search').value = 'BTS';
renderProducts();
view.querySelector('.universe-catalog').scrollIntoView({block: 'start'});
};
}
const grid = launch.querySelector('.artist-launch-grid');
grid.replaceChildren();
activeProducts.filter(product => /\bbts\b/i.test(product.name)).slice(0, 4).forEach(product => {
grid.append(productCard(product));
});
}

function renderProducts() {
const search = view.querySelector('.catalog-search').value.trim().toLocaleLowerCase('es');
const sort = view.querySelector('.catalog-sort').value;
const filtered = activeProducts.filter(product => {
return product.name.toLocaleLowerCase('es').includes(search);
});

if (sort === 'price-up') {
filtered.sort((a, b) => (a.price ?? Infinity) - (b.price ?? Infinity));
} else if (sort === 'price-down') {
filtered.sort((a, b) => (b.price ?? -1) - (a.price ?? -1));
} else if (sort === 'name') {
filtered.sort((a, b) => a.name.localeCompare(b.name, 'es'));
}

const grid = view.querySelector('.universe-product-grid');
grid.replaceChildren();

filtered.forEach(product => {
grid.append(productCard(product));
});

view.querySelector('.catalog-count').textContent = `${filtered.length} de ${activeProducts.length} productos`;
}

function renderHero() {
const variant = selections[current];
const definition = universes[current].variants[variant];
const art = view.querySelector('.hero-art');
art.replaceChildren();

if (current === 'kumo') {
const image = element('img', 'kumo-cinema-image');
image.src = [editorialAssets.kumo, editorialAssets.kumoUpdated, editorialAssets.kumoCyberpunk][variant];
image.decoding = 'async';
const responsive = variant === 0 ? editorialAssets.kumoSrcset
: variant === 1 ? editorialAssets.kumoUpdatedSrcset : null;
if (responsive) {
image.srcset = responsive;
image.sizes = '(max-width: 900px) 100vw, 60vw';
}
image.alt = ['KUMØ / Grand Line', 'Puerto nocturno bajo la lluvia, KUMØ', 'Ciudad nocturna con luces neón, KUMØ'][variant];
image.width = 1672; image.height = 941; image.fetchPriority = 'high';
art.append(image);
}

const supplied = editorialAssets[current + 'Hero'];
art.classList.toggle('editorial-supplied-art', Boolean(supplied));
if (supplied) supplied.forEach((src, index) => {
const figure = element('figure'); const image = element('img');
image.src=src; image.alt=(current === 'f1' ? ['Colapinto','Ayrton Senna','Max Verstappen'] : ['Las Malvinas son argentinas','Coronados de Gloria','Messi y Maradona'])[index];
image.width=1080; image.height=1350; image.fetchPriority='high'; figure.append(image); art.append(figure);
});
const launch = current === 'artistas' && variant >= 5;
const heroProducts = launch && variant === 5 ? editorialAssets.artistasTourProducts
: launch ? activeProducts.filter(product => /\bbts\b/i.test(product.name))
: current === 'artistas' ? activeProducts.slice(0, 2)
: activeProducts;
const heroCount = (current === 'kumo') || Boolean(supplied) ? 0 : Math.min(current === 'artistas' && !launch ? 2 : 3, heroProducts.length);

for (let offset = 0; offset < heroCount; offset++) {
const product = heroProducts[current === 'artistas' && (!launch || variant === 5) ? offset : (variant * 3 + offset) % heroProducts.length];
const figure = element('figure');
const image = element('img');
image.src = product.image;
image.alt = product.name;
image.width = 480;
image.height = 600;
const caption = product.name;
figure.append(image, element('figcaption', '', caption));
art.append(figure);
}

view.dataset.layout = definition[1];
view.toggleAttribute('data-mock-crema', current === 'football' && new URLSearchParams(location.search).get('mock') === '90-crema');
view.style.setProperty('--paper', definition[2]);
view.style.setProperty('--ink', definition[3]);
view.style.setProperty('--accent', definition[4]);
view.querySelector('.hero-copy h1').textContent = launch ? 'ARIRANG' : definition[5];
view.querySelector('.hero-description').textContent = definition[6];
view.querySelector('.hero-kicker').textContent = definition[7];
view.querySelectorAll('.proposal-options button').forEach((button, index) => {
button.setAttribute('aria-pressed', String(index === variant));
});
view.querySelector('.proposal-label').textContent = `${universes[current].name} · Propuesta ${variant + 1} de ${universes[current].variants.length} · ${definition[0]}`;
view.querySelectorAll('.universe-product').forEach(link => {
const url = new URL(link.href);
url.searchParams.set('test_variant', String(variant + 1));
link.href = url.href;
});
renderLaunchProducts();
updateRewards();
}

function renderEditorial() {
if (current === 'bts' || (current === 'artistas' && selections.artistas >= 5)) {
const countdown = element('section', 'bts-countdown');
countdown.setAttribute('aria-label', 'Cuenta regresiva ARIRANG');
countdown.append(element('p', 'countdown-show', countdownConfig.label));
const clock = element('div', 'countdown-clock');
countdown.append(clock);
const target = countdownConfig.target ? Date.parse(countdownConfig.target) : NaN;

if (!Number.isFinite(target)) {
clock.append(element('p', 'countdown-pending', 'Cuenta regresiva / fecha a confirmar'));
} else {
['DÍAS', 'HORAS', 'MIN', 'SEG'].forEach(unit => {
const part = element('div');
part.append(element('strong', '', '00'), element('span', '', unit));
clock.append(part);
});
const update = () => {
const seconds = Math.max(0, Math.floor((target - Date.now()) / 1000));
const values = [Math.floor(seconds / 86400), Math.floor(seconds / 3600) % 24, Math.floor(seconds / 60) % 60, seconds % 60];
clock.querySelectorAll('strong').forEach((node, index) => {
node.textContent = String(values[index]).padStart(2, '0');
});
if (seconds === 0) {
clearInterval(countdownTimer);
countdown.querySelector('.countdown-show').textContent = 'ARIRANG / LLEGÓ EL DÍA';
}
};
update();
countdownTimer = setInterval(update, 1000);
}
view.querySelector('.universe-hero').after(countdown);
}
}

function selectCollection(path) {
if (location.href !== 'about:srcdoc') {
const url = new URL(location.href); url.searchParams.set('coleccion',path); history.replaceState(null,'',url);
}
view.querySelector('.catalog-category').value=path;
view.querySelectorAll('.universe-category-button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.categoryPath===path)));
loadCatalog(path,true);
}

async function loadCatalog(path, includeCategories) {
if (current === 'football' || current === 'f1') {
const ordered = new URL(path, storeOrigin);
ordered.searchParams.set('sort_by', 'best-selling');
path = ordered.pathname + ordered.search;
}
const sequence = ++loadSequence;
const status = view.querySelector('.catalog-status');
const retry = view.querySelector('.catalog-retry');
status.textContent = 'Cargando todos los productos de la categoría…';
view.querySelector('.catalog-search').value = '';
retry.hidden = true;
view.querySelector('.universe-product-grid').setAttribute('aria-busy', 'true');

const controls = view.querySelectorAll('.catalog-search, .catalog-category, .catalog-sort, .universe-category-button');
controls.forEach(control => { control.disabled = true; });

try {
const result = await getCatalog(path, partial => {
if (sequence !== loadSequence || !view) {
return;
}

activeProducts = partial.products;
renderHero();
renderProducts();
status.textContent = 'Cargando colección · ' + partial.products.length + ' de ' + partial.total + ' productos…';
view.querySelector('.catalog-count').textContent =
partial.products.length + ' de ' + partial.total + ' productos · cargando';
});
if (sequence !== loadSequence || !view) {
return;
}

activeProducts = result.products;
controls.forEach(control => { control.disabled = false; });
status.textContent = result.total ? '' : 'Todavía no hay productos visibles en esta categoría.';

if (includeCategories) {
const select = view.querySelector('.catalog-category');
select.replaceChildren(element('option', '', 'Toda la colección'));
select.firstElementChild.value = universes[current].path;
navigation.filter(category => category.path.startsWith(universes[current].path) && category.path !== universes[current].path && !category.name.startsWith('Ver Todo')).forEach(category => {
const option = element('option', '', category.name);
option.value = category.path;
select.append(option);
});
select.value = new URL(path, storeOrigin).pathname;
}

renderHero();
renderProducts();
} catch (error) {
if (sequence !== loadSequence || !view) {
return;
}
view.querySelectorAll('.catalog-category, .universe-category-button').forEach(control => {
control.disabled = false;
});
status.textContent = 'No se pudo cargar la colección completa. Podés volver a intentar.';
status.dataset.loadError = error.message;
retry.hidden = false;
retry.onclick = () => loadCatalog(path, includeCategories);
} finally {
if (sequence === loadSequence && view) {
view.querySelector('.universe-product-grid').setAttribute('aria-busy', 'false');
}
}
}

function openPreview(key) {
const requestedCollection = key === 'bts' ? universes.bts.path : null;
if (key === 'bts') {
key = 'artistas';
selections.artistas = 5;
}

clearInterval(countdownTimer);
if (view) {
view.remove();
}
current = key;
activeProducts = [];
const universe = universes[key];
view = element('section', 'universe-preview');
view.dataset.universe = key;
view.setAttribute('aria-label', `Tienda ${universe.name} · propuestas visuales`);
view.innerHTML = `
<div class="proposal-panel">
<div class="proposal-panel-top">
<button type="button" class="proposal-back">← Volver a STREET 1640</button>
<p class="proposal-label" aria-live="polite"></p>
</div>
<nav class="proposal-options" aria-label="Elegir propuesta visual"></nav>
</div>
<div class="universe-announcement"></div>
<div class="universe-masthead"><strong class="universe-wordmark"></strong><span class="universe-tagline"></span></div>
<div class="universe-hero">
<div class="hero-copy"><p class="hero-kicker"></p><h1></h1><p class="hero-description"></p><a class="hero-cta" href="#universe-catalog">VER COLECCIÓN ↗</a></div>
<div class="hero-art"></div>
</div>
<div class="universe-ribbon"></div>
<section class="universe-catalog" id="universe-catalog" aria-labelledby="universe-catalog-title">
<div class="catalog-title"><div><h2 id="universe-catalog-title">Colección</h2></div><p class="catalog-count" aria-live="polite"></p></div>
<div class="catalog-tools">
<input class="catalog-search" type="search" placeholder="Buscar en esta colección" aria-label="Buscar en esta colección">
<select class="catalog-category" aria-label="Filtrar colección"><option>Toda la colección</option></select>
<select class="catalog-sort" aria-label="Ordenar productos"><option value="default">Orden del catálogo</option><option value="price-up">Precio: menor a mayor</option><option value="price-down">Precio: mayor a menor</option><option value="name">Nombre: A a Z</option></select>
</div>
<p class="catalog-status" role="status"></p><button class="catalog-retry" type="button" hidden>Volver a intentar</button>
<div class="universe-product-grid" aria-busy="true"></div>
</section>
<div class="universe-end"><strong></strong><button class="proposal-back" type="button">← Elegir otro universo</button></div>`;

view.querySelector('.universe-announcement').textContent = universe.label.toUpperCase();
view.querySelector('.universe-wordmark').textContent = universe.name;
view.querySelector('.universe-tagline').textContent = 'STREET 1640 / UNIVERSOS';
if (key === 'football' || key === 'f1') {
view.querySelector('.catalog-sort option[value="default"]').textContent = 'Más vendidos';
}
view.querySelector('.universe-end strong').textContent = universe.name;
renderEditorial();
{
const categories = [{name:'Ver todo',path:universe.path}, ...navigation.filter(c => c.path.startsWith(universe.path) && c.path !== universe.path && !c.name.startsWith('Ver Todo'))];
categories.forEach(c => {
const button = element('button','universe-category-button',c.name); button.type='button'; button.dataset.categoryPath=c.path;
button.setAttribute('aria-pressed',String(c.path === (new URLSearchParams(location.search).get('coleccion') || universe.path)));
button.addEventListener('click',()=> { selectCollection(c.path); view.querySelector('.universe-catalog').scrollIntoView({block:'start',behavior:'auto'}); });
view.querySelector('.universe-ribbon').append(button);
});
}

universe.variants.forEach((definition, index) => {
const button = element('button', '', `${String(index + 1).padStart(2, '0')} · ${definition[0]}`);
button.type = 'button';
button.onclick = () => {
selections[key] = index;
if (key === 'artistas') {
openPreview(key);
return;
}
renderHero();
updatePreviewUrl(key);
};
view.querySelector('.proposal-options').append(button);
});

view.querySelectorAll('.proposal-back').forEach(button => button.addEventListener('click', closePreview));
view.querySelector('.hero-cta').addEventListener('click', event => {
event.preventDefault();
view.querySelector('.universe-catalog').scrollIntoView({ behavior: 'auto', block: 'start' });
});
view.querySelector('.catalog-search').addEventListener('input', renderProducts);
view.querySelector('.catalog-sort').addEventListener('change', renderProducts);
view.querySelector('.catalog-category').addEventListener('change', event => {
selectCollection(event.target.value);
});

view.querySelector('.universe-masthead')?.after(createBenefits());
view.querySelector('.universe-end').before(createConfidence());
main.append(view);
updateRewards();
main.setAttribute('data-universe-preview', key);
renderHero();
updatePreviewUrl(key);
window.scrollTo({ top: 0, left: 0, behavior: 'auto' });
const collection = requestedCollection || new URLSearchParams(location.search).get('coleccion');
const selected = navigation.some(c => c.path === collection && collection.startsWith(universe.path)) ? collection : universe.path;
loadCatalog(selected, true);
}

const landingVariants = [
{
"name": "Portadas",
"layout": "covers"
},
{
"name": "Noche",
"layout": "night"
},
{
"name": "Editorial",
"layout": "editorial"
},
{
"name": "Color Club",
"layout": "color"
},
{
"name": "Studio",
"layout": "studio"
}
]
;
const rewardConfig = {
"currency": "ARS",
"threshold": 95000,
"discountThreshold": 130000,
"discountPercent": 10,
"transferPercent": 10,
"active": false,
"note": "Vista TEST. La barra muestra las metas; no configura envíos ni aplica descuentos al total."
}
;
let demoAmount = null;

function createConfidence() {
const section = element('section', 'purchase-confidence');
section.setAttribute('aria-label', 'Envíos, pagos y ayuda');
section.innerHTML = `<div class="confidence-grid">
<div class="confidence-item">
<svg class="confidence-icon" aria-hidden="true" focusable="false"
xmlns="http://www.w3.org/2000/svg"
width="24"
height="24"
viewBox="0 0 24 24"
fill="none"
stroke="currentColor"
stroke-width="1"
stroke-linecap="round"
stroke-linejoin="round"
>
<path d="M5 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" />
<path d="M15 17a2 2 0 1 0 4 0a2 2 0 1 0 -4 0" />
<path d="M5 17h-2v-11a1 1 0 0 1 1 -1h9v12m-4 0h6m4 0h2v-6h-8m0 -5h5l3 5" />
</svg>
<h2>ENVÍO GRATIS</h2><p>Para compras desde ${new Intl.NumberFormat('es-AR', {style: 'currency', currency: 'ARS', maximumFractionDigits: 0}).format(rewardConfig.threshold)}</p><span>Envíos a todo el país</span></div>
<div class="confidence-item">
<svg class="confidence-icon" aria-hidden="true" focusable="false"
xmlns="http://www.w3.org/2000/svg"
width="24"
height="24"
viewBox="0 0 24 24"
fill="none"
stroke="currentColor"
stroke-width="1"
stroke-linecap="round"
stroke-linejoin="round"
>
<path d="M11.46 20.846a12 12 0 0 1 -7.96 -14.846a12 12 0 0 0 8.5 -3a12 12 0 0 0 8.5 3a12 12 0 0 1 -.09 7.06" />
<path d="M15 19l2 2l4 -4" />
</svg>
<h2>PAGOS SEGUROS</h2><p>Pagá con tarjetas, Mercado Pago o transferencia.</p><a href="${previewUrl('/comorealizarunacompra/')}">Cómo comprar</a></div>
<div class="confidence-item">
<svg class="confidence-icon" aria-hidden="true" focusable="false"
xmlns="http://www.w3.org/2000/svg"
width="24"
height="24"
viewBox="0 0 24 24"
fill="none"
stroke="currentColor"
stroke-width="1"
stroke-linecap="round"
stroke-linejoin="round"
>
<path d="M3 21l1.65 -3.8a9 9 0 1 1 3.4 2.9l-5.05 .9" />
<path d="M9 10a.5 .5 0 0 0 1 0v-1a.5 .5 0 0 0 -1 0v1a5 5 0 0 0 5 5h1a.5 .5 0 0 0 0 -1h-1a.5 .5 0 0 0 0 1" />
</svg>
<h2>¿NECESITÁS AYUDA?</h2><p>Te asesoramos con tu compra y la elección de tu talle.</p><a href="https://wa.me/541122530060" target="_blank" rel="noopener">Escribinos por WhatsApp</a></div>
</div>`;
return section;
}

function cartAmount() {
const subtotal = document.querySelector('#modal-cart .js-cart-subtotal');
const value = (subtotal?.textContent || '0').replace(/[^\d,.-]/g, '').replace(/\./g, '').replace(',', '.');
return Math.max(0, Number(value) || 0);
}

function updateRewards() {
const source = current && view ? view : parent;
const palette = getComputedStyle(source);
const universe = current || 'landing';
const layout = source.dataset.layout || source.dataset.homeLayout;
const tokens = {
'--reward-paper': palette.getPropertyValue(current ? '--paper' : '--home-bg').trim(),
'--reward-ink': palette.getPropertyValue(current ? '--ink' : '--home-ink').trim(),
'--reward-accent': palette.getPropertyValue(current ? '--accent' : '--home-accent').trim(),
'--reward-font': palette.fontFamily
};
if (universe === 'artistas') {
tokens['--reward-paper'] = '#fff1df';
tokens['--reward-ink'] = '#ba181e';
tokens['--reward-accent'] = '#ba181e';
}
document.dispatchEvent(new CustomEvent('test-universe-theme', {detail: {
universe,
variant: current ? selections[current] + 1 : 1,
layout,
paper: tokens['--reward-paper'],
ink: tokens['--reward-ink'],
accent: tokens['--reward-accent'],
font: tokens['--reward-font']
}}));

const amount = demoAmount === null ? cartAmount() : demoAmount;
const threshold = rewardConfig.threshold;
const discountThreshold = rewardConfig.discountThreshold;
const percent = Math.min(100, Math.max(0, amount / discountThreshold * 100));
document.querySelectorAll('.reward-progress').forEach(section => {
section.dataset.rewardUniverse = universe;
section.dataset.rewardLayout = layout;
section.dataset.rewardBrand = parent.dataset.brandPreview;

Object.entries(tokens).forEach(([name, value]) => {
section.style.setProperty(name, value);
});

section.querySelector('.reward-message').textContent = amount >= discountThreshold
? 'Metas alcanzadas: envío gratis + 10% OFF'
: amount >= threshold
? `Envío gratis alcanzado. Te faltan ${money.format(discountThreshold - amount)} para sumar 10% OFF`
: `Te faltan ${money.format(threshold - amount)} para envío gratis`;
section.querySelector('.reward-fill').style.width = percent + '%';
const track = section.querySelector('.reward-track');
track.setAttribute('aria-valuenow', String(Math.floor(percent * 100) / 100));
track.setAttribute('aria-valuetext', `${money.format(amount)}. Envío gratis desde ${money.format(threshold)}; 10% OFF desde ${money.format(discountThreshold)}`);
section.querySelector('.reward-current').textContent = `${demoAmount === null ? 'Carrito' : 'Simulación TEST'}: ${money.format(amount)}`;
section.querySelector('.reward-shipping-goal').classList.toggle('reward-unlocked', amount >= threshold);
section.querySelector('.reward-discount-goal').classList.toggle('reward-unlocked', amount >= discountThreshold);
});
}

function createBenefits() {
const section = element('section', 'universe-benefits');
section.setAttribute('aria-label', 'Beneficios de compra');
const items = [
`Envío gratis desde ${money.format(rewardConfig.threshold)}`,
'Envíos a todo el país',
`${rewardConfig.discountPercent}% OFF desde ${money.format(rewardConfig.discountThreshold)}`,
`${rewardConfig.transferPercent}% OFF abonando con transferencia`
];
const track = element('div', 'benefits-marquee');

[false, true].forEach(duplicate => {
const group = element('div', 'benefits-group');
if (duplicate) {
group.setAttribute('aria-hidden', 'true');
}
items.forEach(text => group.append(element('span', '', text)));
track.append(group);
});
section.append(track);
return section;
}

function initializePortal() {
initializeBannerMock();
let selected = 0;
if (!Number.isInteger(selected) || selected < 0 || selected >= landingVariants.length) {
selected = 0;
}
const options = parent.querySelector('.home-proposal-options');
const apply = index => {
selected = index;
parent.dataset.homeLayout = landingVariants[index].layout;
parent.dataset.brandPreview = 'STREET';
parent.querySelector('.portal-masthead h1').innerHTML = 'STREET <span>1640</span>';
parent.querySelector('.home-proposal-label').textContent = `Propuesta ${index + 1} de ${landingVariants.length} · ${landingVariants[index].name}`;
options.querySelectorAll('button').forEach((button, offset) => button.setAttribute('aria-pressed', String(offset === index)));
if (location.href !== 'about:srcdoc') {
const url = new URL(location.href);
url.searchParams.set('landing', String(index + 1));
history.replaceState(null, '', url);
}
updateRewards();
};
landingVariants.forEach((variant, index) => {
const button = element('button', '', `${String(index + 1).padStart(2, '0')} · ${variant.name}`);
button.type = 'button';
button.onclick = () => apply(index);
options.append(button);
});
apply(selected);
initializeBestSellers();
parent.querySelector('.portal-trust-host').append(createConfidence());
parent.querySelector('.portal-masthead').after(createBenefits());
updateRewards();

const host = parent.querySelector('.portal-countdown');
host.append(element('p', '', countdownConfig.label));
const clock = element('div', 'countdown-clock');
host.append(clock);
['DÍAS', 'HORAS', 'MIN', 'SEG'].forEach(unit => {
const part = element('div');
part.append(element('strong', '', '00'), element('span', '', unit));
clock.append(part);
});
const target = Date.parse(countdownConfig.target);
const update = () => {
const seconds = Math.max(0, Math.floor((target - Date.now()) / 1000));
const values = [Math.floor(seconds / 86400), Math.floor(seconds / 3600) % 24, Math.floor(seconds / 60) % 60, seconds % 60];
clock.querySelectorAll('strong').forEach((node, index) => { node.textContent = String(values[index]).padStart(2, '0'); });
};
update();
setInterval(update, 1000);
}

// A query-only proposal: the current landing keeps its original banners.
function initializeBannerMock() {
if (new URLSearchParams(location.search).get('banner_mock') !== 'archivo-cartelera') {
return;
}

parent.dataset.bannerMock = 'archivo-cartelera';
const football = parent.querySelector('.portal-football');
const artists = parent.querySelector('.portal-artists');
football.setAttribute('aria-label', 'Ver la colección 90 de fútbol');
artists.setAttribute('aria-label', 'Ver la colección ARTISTAS');
football.querySelector('.portal-banner-copy').innerHTML =
'<h2>90</h2><p>El fútbol que llevás puesto.</p><span class="portal-enter">VER FÚTBOL ↗</span>';
artists.querySelector('.portal-banner-copy').innerHTML =
'<h2>ARTISTAS</h2><p>Tu música. Tu remera.</p><span class="portal-enter">VER ARTISTAS ↗</span>';

const visuals = [
[football, editorialAssets.footballHero.slice(1), ['Coronados de Gloria', 'Messi y Maradona']],
[artists, [
'https://acdn-us.mitiendanube.com/stores/004/626/860/products/mockup-airbag-1-77f481b83d3fa5296e17668472294087-480-0.webp',
'https://acdn-us.mitiendanube.com/stores/004/626/860/products/bad-2da-capsula-web-7-7ceb1771759d40bd0317694702395816-480-0.webp'
], ['AIRBAG', 'BAD BUNNY']]
];

visuals.forEach(([banner, sources, labels]) => {
const art = element('div', 'banner-mock-images');
sources.forEach((src, index) => {
const figure = element('figure');
const image = element('img');
image.src = src;
image.alt = labels[index];
image.width = 480;
image.height = 600;
image.loading = 'lazy';
image.decoding = 'async';
figure.append(image, element('figcaption', '', labels[index]));
art.append(figure);
});
banner.append(art);
});
}


function initializeBestSellers() {
const host = parent.querySelector('.portal-bestsellers');
if (!host) {
return;
}

const pending = [];
const loaders = new Map();
const carousels = [];
const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
let activeLoads = 0;

const visibilityObserver = typeof IntersectionObserver === 'function'
? new IntersectionObserver(entries => {
entries.forEach(entry => {
const carousel = carousels.find(item => item.section === entry.target);
if (carousel) {
carousel.visible = entry.isIntersecting;
}
});
}, { threshold: .15 })
: null;

// One clock for all shelves; only visible, idle carousels advance.
setInterval(() => {
carousels.forEach(carousel => {
if (carousel.visible && !document.hidden
&& parent.getClientRects().length && Date.now() >= carousel.nextAt) {
carousel.advance(1);
}
});
}, 1000);

const drain = () => {
while (activeLoads < 2 && pending.length) {
const load = pending.shift();
activeLoads++;

load().finally(() => {
activeLoads--;
drain();
});
}
};

const observer = typeof IntersectionObserver === 'function'
? new IntersectionObserver(entries => {
entries.forEach(entry => {
if (!entry.isIntersecting) {
return;
}

const load = loaders.get(entry.target);
observer.unobserve(entry.target);
loaders.delete(entry.target);
pending.push(load);
});

drain();
}, { rootMargin: '500px 0px' })
: null;

['bts', 'kumo', 'football', 'artistas', 'f1'].forEach(key => {
const universe = universes[key];
const section = element('section', 'home-bestseller-section');
section.dataset.catalogUniverse = key;
const heading = element('div', 'home-bestseller-heading');
const title = element('div');
title.append(element('p', '', 'MÁS VENDIDOS'));
title.append(element('h2', '', universe.name));
const more = element('a', 'home-bestseller-more', 'VER MÁS ↗');
more.href = '#' + universe.hash;
more.setAttribute('aria-label', 'Ver más de ' + universe.name);
heading.append(title, more);

const status = element('p', 'home-bestseller-status', 'Cargando los más vendidos…');
status.setAttribute('role', 'status');
const grid = element('div', 'home-bestseller-grid');
grid.id = 'bestsellers-' + key;
grid.setAttribute('role', 'region');
grid.setAttribute('aria-label', 'Productos más vendidos de ' + universe.name);
grid.setAttribute('aria-roledescription', 'carrusel');
grid.tabIndex = 0;
grid.setAttribute('aria-busy', 'true');
const controls = element('div', 'home-bestseller-controls');
controls.hidden = true;
const previous = element('button');
const next = element('button');
previous.innerHTML = '<svg aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" > <path d="M15 6l-6 6l6 6" /> </svg>';
next.innerHTML = '<svg aria-hidden="true" focusable="false" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" > <path d="M9 6l6 6l-6 6" /> </svg>';
[previous, next].forEach(button => {
button.type = 'button';
button.setAttribute('aria-controls', grid.id);
controls.append(button);
});
previous.setAttribute('aria-label', 'Productos anteriores de ' + universe.name);
next.setAttribute('aria-label', 'Productos siguientes de ' + universe.name);
const carousel = {
section, visible: !visibilityObserver, nextAt: Date.now() + 3000,
advance(direction) {
const maximum = grid.scrollWidth - grid.clientWidth;
const card = grid.firstElementChild;
if (!card || maximum <= 1) {
return;
}

const step = card.getBoundingClientRect().width + parseFloat(getComputedStyle(grid).columnGap);
let target = grid.scrollLeft + direction * step;
if (direction > 0 && grid.scrollLeft >= maximum - 2) {
target = 0;
} else if (direction < 0 && grid.scrollLeft <= 2) {
target = maximum;
}

grid.scrollTo({ left: Math.max(0, Math.min(maximum, target)), behavior: reducedMotion.matches ? 'auto' : 'smooth' });
carousel.nextAt = Date.now() + 3000;
}
};
const delayAdvance = () => {
carousel.nextAt = Date.now() + 3000;
};
previous.onclick = () => carousel.advance(-1);
next.onclick = () => carousel.advance(1);
grid.addEventListener('pointerdown', delayAdvance);
grid.addEventListener('wheel', delayAdvance, { passive: true });
grid.addEventListener('keydown', event => {
if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
event.preventDefault();
carousel.advance(event.key === 'ArrowRight' ? 1 : -1);
}
});
carousels.push(carousel);
if (visibilityObserver) {
visibilityObserver.observe(section);
}
const retry = element('button', 'home-bestseller-retry', 'Volver a intentar');
retry.type = 'button';
retry.hidden = true;
section.append(heading, status, retry, grid, controls);
host.append(section);

const load = async () => {
retry.hidden = true;
status.textContent = 'Cargando los más vendidos…';
grid.setAttribute('aria-busy', 'true');

try {
const url = new URL(previewUrl(universe.path));
url.searchParams.set('sort_by', 'user');
const catalog = await getCatalogPage(url.href);
grid.replaceChildren();
catalog.products.slice(0, 8).forEach(product => {
grid.append(productCard(product, key));
});
section.dataset.catalogSort = 'user';
controls.hidden = grid.childElementCount < 2;
status.textContent = catalog.products.length ? '' : 'Todavía no hay prendas en esta colección.';
} catch (error) {
status.textContent = 'No se pudo cargar la selección. Podés volver a intentar o abrir la colección.';
retry.hidden = false;
} finally {
grid.setAttribute('aria-busy', 'false');
}
};

retry.onclick = () => {
pending.push(load);
drain();
};

if (observer) {
loaders.set(section, load);
observer.observe(section);
} else {
pending.push(load);
}
});

if (!observer) {
drain();
}
}



document.addEventListener('click', event => {
const link = event.target.closest('.topic-universes-menu a[data-topic-path]');
if (!link || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
const path=link.dataset.topicPath;
const key=Object.keys(universes).sort((a,b)=>universes[b].path.length-universes[a].path.length).find(k=>path.startsWith(universes[k].path));
if (!key) return;
event.preventDefault();
if (location.href !== 'about:srcdoc') {
const url=new URL(link.href); history.replaceState(null,'',url);
}
openPreview(key);
});
window.addEventListener('hashchange', () => {
const key=Object.keys(universes).find(k=>location.hash === '#'+universes[k].hash);
if (key && key !== current) openPreview(key);
});
initializePortal();
Object.keys(universes).forEach(key => {
parent.querySelectorAll('a[href="#' + universes[key].hash + '"]').forEach(entry => {
entry.dataset.universe = key;
entry.addEventListener('click', event => {
event.preventDefault();
event.stopImmediatePropagation();
openPreview(key);
}, true);
});
});

const initial = Object.keys(universes).find(key => location.hash === '#' + universes[key].hash);
if (initial) {
openPreview(initial);
}
})();
}
