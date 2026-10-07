// Copia fiel del <script> del bloque de código original (footer · code_4ra5).
// Se ejecuta tal cual desde su módulo; el refactor a clases queda para cuando haya preview para verificar.
export function run() {
(function () {
'use strict';
// Use the same native drawer for successful additions and the header cart.
function configureNativeCart() {
const cart = document.getElementById('modal-cart');
if (cart) {
cart.setAttribute('data-cart-open-type', 'show_cart');
}
}
configureNativeCart();
if (document.readyState === 'loading') {
document.addEventListener('DOMContentLoaded', configureNativeCart, {once: true});
}
const params = new URLSearchParams(location.search);
const storeOrigin = location.href === 'about:srcdoc' ? 'https://street1640shop.mitiendanube.com' : location.origin;
const isTest = location.href === 'about:srcdoc' || params.get('preview_theme_installation_id') === '14559883';
function syncDraftOffset() {
const bar = document.getElementById('draft-bar');
const height = bar && !bar.classList.contains('is-collapsed') && getComputedStyle(bar).display !== 'none' ? Math.max(0, bar.getBoundingClientRect().bottom) : 0;
document.documentElement.style.setProperty('--street-draft-offset', height + 'px');
}
syncDraftOffset();
const draftBar = document.getElementById('draft-bar');
if (draftBar) {
new MutationObserver(syncDraftOffset).observe(draftBar, {attributes: true});
if (typeof ResizeObserver === 'function') {
new ResizeObserver(syncDraftOffset).observe(draftBar);
}
}
window.addEventListener('resize', syncDraftOffset, {passive: true});
new MutationObserver(syncDraftOffset).observe(document.body, {childList: true});

document.querySelectorAll('#ns-section-footer .footer-menu-title').forEach(title => {
if (title.textContent.trim() === 'Tu título acá') {
title.hidden = true;
}
});
const relatedTitle = document.querySelector('#ns-section-alternative_products .heading-block');
if (relatedTitle?.textContent.trim() === 'Tu título acá') {
relatedTitle.textContent = 'También te puede gustar';
}

const universes = {"kumo":{"name":"KUMØ","path":"/anime/","label":"KUMØ / 雲","hash":"kumo-preview","ribbon":["ONE PIECE","DRAGON BALL","NARUTO"],"variants":[["KUMØ Original","kumo-reference","#0b1020","#c8a56a","#cbbc99","KUMØ","","KUMØ / 雲"],["KUMØ Updated","kumo-updated","#0b1020","#c8a56a","#cbbc99","KUMØ","Anime para llevar con vos.","KUMØ / 雲"],["KUMØ Cyberpunk","kumo-cyberpunk","#050607","#e5eeed","#64f5e7","KUMØ","Tu universo, después de medianoche.","ANIME / 雲"]]},"football":{"name":"90","path":"/futbol-noventa/","label":"90 MINUTOS Fútbol / Edición archivo","hash":"football-preview","ribbon":["SELECCIÓN ARGENTINA","ÍDOLOS","ARCHIVO 90 MINUTOS"],"variants":[["Tapa 90","football-cover","#fff6d7","#161616","#e62d20","90","","90 MINUTOS FÚTBOL / EDICIÓN 01"],["Don Fútbol","football-teal","#087480","#fff5cb","#ffdf2a","90 MINUTOS FÚTBOL","","ARCHIVO / ARGENTINA / SELECCIÓN"],["El Suplemento","football-paper","#fff0c9","#072f72","#f02d2a","EL SUPLEMENTO","","90 / FÚTBOL ARGENTINO"],["El Póster","football-poster","#f1db38","#10276a","#ec2e24","FÚTBOL 90 MINUTOS","","SELECCIÓN / RETRO / ARGENTINA"],["Figuritas","football-stickers","#174db2","#fff6d6","#ed4d1c","90 CLUB","","ÁLBUM / 90 MINUTOS FÚTBOL"]]},"bts":{"name":"BTS / ARIRANG","path":"/artistas1/bts/","label":"BTS World Tour · ARIRANG","hash":"bts-preview","ribbon":["BTS","ARIRANG","WORLD TOUR / 2026"],"variants":[["Tour Rojo","bts-red","#ba181e","#fff5e8","#191919","ARIRANG","","BTS / WORLD TOUR"],["Army Night","bts-night","#10101d","#faf4ff","#c5a0ff","BTS / ARIRANG","","ARGENTINA / 2026"],["Entrada","bts-ticket","#f2ecdf","#201e1b","#bd2326","ARIRANG","","BTS WORLD TOUR / ARGENTINA"],["Purple Room","bts-purple","#d6c2f2","#332252","#faf7f0","BTS","","ARIRANG / WORLD TOUR"],["Setlist","bts-setlist","#fcf4e5","#252321","#ad202b","ARIRANG / 2026","","BTS / ARGENTINA"]]},"artistas":{"name":"ARTISTAS","path":"/artistas1/","label":"ARTISTAS","hash":"artistas-preview","ribbon":["ARTISTAS","BTS / ARIRANG","STREET 1640"],"variants":[["Doble Cara","artists-split","#151515","#fff4e2","#e66936","ARTISTAS","","ARTISTAS / COLLECTION"],["Disquería","artists-record","#f2e5c9","#211e1b","#256b58","ARTISTAS","","ARTISTAS / STREET 1640"],["Flyers","artists-flyers","#eade30","#17203a","#df37a3","ARTISTAS","","ARTISTAS / STREET 1640"],["Sesiones","artists-sessions","#ece8e1","#202320","#293f8e","ARTISTAS / 01","","OASIS · AIRBAG / BAD BUNNY · DUKI"],["Pared de Afiches","artists-wall","#1b213a","#f4eee0","#f05635","ARTISTAS","","ARTISTAS / STREET 1640"],["Lanzamiento Rojo","artists-launch-red","#ba181e","#fff5e8","#191919","ARIRANG","","BTS / WORLD TOUR"],["Edición ARIRANG","artists-launch-paper","#f2ecdf","#241915","#bd2326","ARTISTAS","","LANZAMIENTO / BTS · ARIRANG"],["Army Night","artists-launch-night","#10101d","#faf4ff","#c5a0ff","ARTISTAS","","LANZAMIENTO / BTS · ARIRANG"],["Cartelera","artists-launch-posters","#f4efe5","#191919","#bd2326","ARTISTAS","","LANZAMIENTO / BTS · ARIRANG"],["Backstage","artists-launch-gallery","#dedbd3","#222222","#ae2728","ARTISTAS","","LANZAMIENTO / BTS · ARIRANG"]]},"f1":{"name":"F1","path":"/formula-12/","label":"F1 / MOTORSPORT","hash":"f1-preview","ribbon":["COLAPINTO","FERRARI","MCLAREN","RED BULL"],"variants":[["Pit Lane","f1-pit","#101114","#f0eee8","#ef3025","F1","","MOTORSPORT / PIT LANE"],["Paddock","f1-paddock","#f2efe5","#191919","#df2d21","PADDOCK","","F1 / EDICIÓN 02"],["Telemetry","f1-telemetry","#081d18","#d3f2da","#a9e92f","TELEMETRY","","F1 / SECTOR 03"],["Grid","f1-grid","#f6eecc","#101a38","#1649d6","THE GRID","","F1 / EDICIÓN 04"],["Monochrome","f1-mono","#e6e6e3","#181818","#555555","F1 / ARCHIVE","","MOTORSPORT / 05"]]}};
const navigation = [{"name":"FORMULA 1","path":"/formula-12/"},{"name":"Ver Todo","path":"/formula-12/ver-todo/"},{"name":"Escuderias","path":"/formula-12/escuderias/"},{"name":"Pilotos","path":"/formula-12/historicos/"},{"name":"Diseños","path":"/formula-12/disenos/"},{"name":"ARTISTAS","path":"/artistas1/"},{"name":"Ver Todo","path":"/artistas1/ver-todo1/"},{"name":"Bad Bunny","path":"/artistas1/bad-bunny/"},{"name":"Oasis","path":"/artistas1/oasis/"},{"name":"Duki","path":"/artistas1/duki/"},{"name":"Trueno","path":"/artistas1/trueno/"},{"name":"ELADIO CARRION","path":"/artistas1/eladio-carrion/"},{"name":"SABRINA CARPENTER","path":"/artistas1/sabrina-carpenter/"},{"name":"TINI","path":"/artistas1/tini/"},{"name":"OMAR COURTZ","path":"/artistas1/omar-courtz/"},{"name":"BTS","path":"/artistas1/bts/"},{"name":"ANIME × KUMØ","path":"/anime/"},{"name":"Ver Todo","path":"/anime/ver-todo3/"},{"name":"One Piece","path":"/anime/one-piece/"},{"name":"Demon Slayer","path":"/anime/demon-slayer/"},{"name":"Dragon Ball","path":"/anime/dragon-ball/"},{"name":"Attack On Titan","path":"/anime/attack-on-titan/"},{"name":"Naruto","path":"/anime/naruto/"},{"name":"Jujutsu Kaisen","path":"/anime/jujutsu-kaisen/"},{"name":"FÚTBOL × 90","path":"/futbol-noventa/"},{"name":"Ver Todo","path":"/futbol-noventa/ver-todo2/"},{"name":"Idolos","path":"/futbol-noventa/idolos/"},{"name":"Argentina","path":"/futbol-noventa/argentina/"},{"name":"Red Bull","path":"/formula-12/escuderias/red-bull/"},{"name":"Ferrari","path":"/formula-12/escuderias/ferrari/"},{"name":"McLaren","path":"/formula-12/escuderias/mclaren/"},{"name":"Mercedez","path":"/formula-12/escuderias/mercedez/"},{"name":"Alpine","path":"/formula-12/escuderias/alpine/"}];
const rewardConfig = {"currency":"ARS","threshold":95000,"discountThreshold":130000,"discountPercent":10,"transferPercent":10,"active":false,"note":"Vista TEST. La barra muestra las metas; no configura envíos ni aplica descuentos al total."};
const parent = document.getElementById('MainContent');
if (!parent || document.body.dataset.testSharedReady) {
return;
}
document.body.dataset.testSharedReady = 'true';
const home = parent.querySelector('.parent-universes');
const landingNumber = 1;
const landingBrand = 'STREET1640';
let current = params.get('test_universe');
if (!universes[current]) {
const paths = [location.pathname, ...Array.from(parent.querySelectorAll('.breadcrumbs a[href]'), link => new URL(link.getAttribute('href'), storeOrigin).pathname)];
current = Object.keys(universes).sort((a, b) => universes[b].path.length - universes[a].path.length).find(key => paths.some(path => path.startsWith(universes[key].path))) || 'landing';
}
if (current === 'bts') {
current = 'artistas';
params.set('test_variant', '6');
}
let index = 0;
const selections = { kumo: 1, football: 1, artistas: 5, bts: 5, f1: 0 };
const view = parent;
const money = new Intl.NumberFormat('es-AR', {style: 'currency', currency: 'ARS'});
let demoAmount = null;

function element(tag, className, text) {
const node = document.createElement(tag);
if (className) {
node.className = className;
}
if (text) {
node.textContent = text;
}
return node;
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



const header = document.querySelector('.js-header');
if (header && !header.querySelector('.topic-site-nav')) {
const nav = element('nav', 'topic-site-nav');
nav.setAttribute('aria-label', 'Navegación de la tienda TEST');
[
['Inicio', '/'], ['Universos', null], ['Contacto', '/contacto/'],
['Política de devolución', '/devoluciones/'],
['Acerca de nosotros', '/acerca-de-nosotros/'],
['Cómo realizar una compra', '/comorealizarunacompra/']
].forEach(([label, path]) => {
if (!path) {
const button = element('button', 'topic-universes-toggle', 'Universos ⌄');
button.type = 'button'; button.setAttribute('aria-expanded', 'false'); button.setAttribute('aria-controls', 'test-universes-menu'); nav.append(button);
const panel = element('div', 'topic-universes-menu'); panel.id = 'test-universes-menu'; panel.hidden = true;
const close = () => { panel.hidden = true; button.setAttribute('aria-expanded', 'false'); };
['football', 'kumo', 'artistas', 'f1'].forEach(key => {
const group = element('section', 'topic-universe-group');
const title = element('a', 'topic-universe-title', {football:"90'",kumo:'KUMO',artistas:'Artistas',f1:'F1'}[key]); title.dataset.topicPath = title.href = universes[key].path; const heading = element('h2'); heading.append(title); group.append(heading);
const all = element('a', '', 'Ver todo ↗'); all.dataset.topicPath = universes[key].path; all.href = universes[key].path; group.append(all);
navigation.filter(c => c.path.startsWith(universes[key].path) && c.path !== universes[key].path && !c.name.startsWith('Ver Todo')).sort((a,b) => a.path.localeCompare(b.path)).forEach(c => {
const link = element('a', 'topic-universe-category', c.name === 'Argentina' ? 'Selección Argentina' : c.name);
link.dataset.topicPath = c.path; link.href = c.path;
if (c.path.split('/').filter(Boolean).length > 2) link.classList.add('topic-subcategory'); group.append(link);
}); panel.append(group);
});
const allCatalog = element('section', 'topic-universe-group topic-all-catalog');
const catalogLink = element('a', '', 'Ver todos los productos ↗');
catalogLink.dataset.topicPath = '/productos/';
catalogLink.href = '/productos/';
allCatalog.append(catalogLink);
panel.prepend(allCatalog);
header.append(panel);
panel.addEventListener('click', e => { if (e.target.closest('a')) close(); });
button.addEventListener('click', () => { panel.hidden = !panel.hidden; button.setAttribute('aria-expanded', String(!panel.hidden)); });
document.addEventListener('click', e => { if (!panel.contains(e.target) && !button.contains(e.target)) close(); });
document.addEventListener('keydown', e => { if (e.key === 'Escape' && !panel.hidden) { close(); button.focus(); } }); return;
}
const link = element('a', '', label);
link.dataset.topicPath = path;
link.href = new URL(path, storeOrigin).href;
nav.append(link);
});
header.append(nav);
}

const contextualUrl = path => {
const url = new URL(path, storeOrigin);
if (isTest) { url.searchParams.set('preview_theme_installation_id', '14559883'); } else { url.searchParams.delete('preview_theme_installation_id'); }
url.searchParams.set('landing', '1');
if (url.pathname !== '/') {
url.searchParams.set('test_universe', current);
url.searchParams.set('test_variant', String(index + 1));
}
return url;
};

function rewriteLinks() {
document.querySelectorAll('a[href]').forEach(link => {
const raw = link.dataset.topicPath || link.getAttribute('href');
if (!raw || raw.startsWith('#')) {
return;
}
let url;
try {
url = new URL(raw, storeOrigin);
} catch {
return;
}
if (url.origin !== storeOrigin) {
return;
}
if (url.pathname === '/productos/') {
const allProducts = contextualUrl('/productos/');
allProducts.searchParams.delete('test_universe');
allProducts.searchParams.delete('test_variant');
link.href = allProducts.href;
return;
}
const category = Object.keys(universes).find(key => url.pathname.startsWith(universes[key].path));
if (category) {
if (/\/ver-todo\d*\/$/.test(url.pathname)) url.pathname=universes[category].path;
link.dataset.topicPath = url.pathname;
const target = contextualUrl('/');
target.hash = universes[category].hash;
if (url.pathname !== universes[category].path) target.searchParams.set("coleccion", url.pathname);
target.searchParams.set('propuesta', String(selections[category] + 1));
link.href = target.href;
return;
}
const pages = ['/contacto/', '/devoluciones/', '/acerca-de-nosotros/', '/comorealizarunacompra/'];
if (pages.includes(url.pathname) || url.pathname.startsWith('/productos/')) {
if (home && link.classList.contains('universe-product')) {
return;
}
if (isTest) { url.searchParams.set('preview_theme_installation_id', '14559883'); } else { url.searchParams.delete('preview_theme_installation_id'); }
url.searchParams.set('landing', '1');
url.searchParams.set('test_universe', current);
url.searchParams.set('test_variant', String(index + 1));
if (url.pathname === '/productos/' && universes[current]) {
url = contextualUrl('/');
url.searchParams.set('propuesta', String(index + 1));
url.hash = universes[current].hash;
}
link.href = url.href;
} else if (url.pathname === '/' && !url.hash) {
link.href = contextualUrl('/').href;
}
});
}

function applyTheme(context) {
current = universes[context.universe] ? context.universe : 'landing';
index = Math.max(0, (Number(context.variant) || 1) - 1);
document.body.dataset.testProductUniverse = current;
parent.dataset.brandPreview = home ? home.dataset.brandPreview : landingBrand;
['paper', 'ink', 'accent'].forEach(name => {
document.body.style.setProperty('--' + name, context[name]);
if (!home) {
parent.style.setProperty('--' + name, context[name]);
}
});
document.body.style.setProperty('--topic-font', context.font || 'Arial, sans-serif');
if (!home) {
parent.dataset.layout = context.layout;
}
rewriteLinks();
}

if (home) {
const active = parent.querySelector('.universe-preview') || home;
const palette = getComputedStyle(active);
const key = active.dataset.universe || 'landing';
applyTheme({universe: key, variant: params.get('propuesta') || 1,
paper: palette.getPropertyValue(key === 'landing' ? '--home-bg' : '--paper').trim(),
ink: palette.getPropertyValue(key === 'landing' ? '--home-ink' : '--ink').trim(),
accent: palette.getPropertyValue(key === 'landing' ? '--home-accent' : '--accent').trim(),
font: palette.fontFamily});
document.addEventListener('test-universe-theme', event => applyTheme(event.detail));
return;
}

const universe = universes[current];
index = universe ? selections[current] : 0;
const streetLandings = [
['STREET1640','covers','#f3eee2','#181818','#bd242b'],
['STREET1640','night','#0c0b18','#f0e8ff','#b28ff5'],
['STREET1640','editorial','#f6f0e6','#2a2925','#825f38'],
['STREET1640','color','#faf0d5','#202442','#de3e2a'],
['STREET1640','studio','#ffffff','#252525','#525252']
];
const definition = universe?.variants[index]
|| streetLandings[landingNumber-1]
|| streetLandings[0];
applyTheme({universe: current, variant: index + 1, layout: definition[1],
paper: current === 'artistas' ? '#fff1df' : definition[2],
ink: current === 'artistas' ? '#ba181e' : definition[3], accent: definition[4],
font: current === 'landing' ? (landingNumber <= 5 ? 'Arial, sans-serif' : "'Courier New', monospace")
: definition[1] === 'f1-telemetry' ? 'monospace' : 'Arial, sans-serif'});

const heading = element('nav', 'test-product-heading');
heading.setAttribute('aria-label', 'Volver al universo');
const back = element('a', '', '← ' + (universe?.name || landingBrand));
const target = contextualUrl('/');
if (universe) {
target.searchParams.set('propuesta', String(index + 1));
target.hash = universe.hash;
}
back.href = target.href;
heading.append(back, element('strong', '', universe?.name || landingBrand));
parent.prepend(heading, createBenefits());

if (document.getElementById('product_form')) {
const info = parent.querySelector('#ns-block-purchase_info');
if (info) {
info.replaceChildren();
const returns = element('div', 'topic-assurance');
returns.append(element('strong', '', 'Cambios y devoluciones'),
element('p', '', 'Consultá las condiciones vigentes antes de comprar.'));
const policy = element('a', '', 'Ver política de devolución ↗');
policy.href = contextualUrl('/devoluciones/').href;
returns.append(policy);
const secure = element('div', 'topic-assurance');
secure.append(element('strong', '', 'Compra segura'),
element('p', '', 'Pagá con los medios habilitados en Tiendanube y consultanos ante cualquier duda.'));
const help = element('a', '', 'Cómo realizar una compra ↗');
help.href = contextualUrl('/comorealizarunacompra/').href;
secure.append(help);
info.append(returns, secure);
}
} else {
parent.classList.add('topic-information-page');
}

})();
}
