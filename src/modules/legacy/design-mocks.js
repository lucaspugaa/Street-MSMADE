// Copia fiel del <script> del bloque de código original (footer · code_t648).
// Se ejecuta tal cual desde su módulo; el refactor a clases queda para cuando haya preview para verificar.
export function run() {
(function () {
'use strict';
// Comparador visible solo en la preview de TEST: diseño actual vs mock, en 90 y en KUMØ.
if (window.streetMockSwitch) {
return;
}
window.streetMockSwitch = true;
const isTest = location.href === 'about:srcdoc'
|| new URLSearchParams(location.search).get('preview_theme_installation_id') === '14559883';
if (!isTest) {
return;
}
// Banner del mock KUMØ Nubes, subido a Tiendanube (ver PLAN.md). Sin URL https el banner actual se conserva.
const KUMO_NUBES_SRC = 'https://acdn-us.mitiendanube.com/stores/004/626/860/media/c8a5baf2-kumo-nubes-banner-v3/source.webp';
const KUMO_NUBES_PAPER = '#0A1319';
const mocks = {
football: {value: '90-crema', label: '90 Crema', title: 'DISEÑO 90', attribute: 'data-mock-crema'},
kumo: {value: 'kumo-nubes', label: 'KUMØ Nubes', title: 'DISEÑO KUMØ', attribute: 'data-mock-nubes'}
};
let bodyPaper = null;
let nubesImageObserver = null;
let nubesImageView = null;
const bar = document.createElement('div');
bar.className = 'street-mock-switch';
bar.setAttribute('role', 'group');
bar.hidden = true;
const title = document.createElement('span');
const actual = document.createElement('button');
const mock = document.createElement('button');
actual.type = 'button';
mock.type = 'button';
actual.textContent = 'Actual';
actual.addEventListener('click', () => apply(false));
mock.addEventListener('click', () => apply(true));
bar.append(title, actual, mock);
function target() {
const main = document.getElementById('MainContent');
const key = main && main.getAttribute('data-universe-preview');
const view = key && mocks[key] ? main.querySelector('.universe-preview') : null;
return view ? {key, view} : null;
}
function selected(key) {
return new URLSearchParams(location.search).get('mock') === mocks[key].value;
}
function apply(on) {
const current = target();
if (!current) {
return;
}
if (location.href !== 'about:srcdoc') {
const url = new URL(location.href);
if (on) {
url.searchParams.set('mock', mocks[current.key].value);
} else {
url.searchParams.delete('mock');
}
history.replaceState(null, '', url);
}
setMock(current, on);
sync(on);
}
function setMock(current, on) {
current.view.toggleAttribute(mocks[current.key].attribute, on);
if (current.key === 'kumo') {
paintKumo(current.view, on);
}
}
// KUMØ Nubes: fondo #0A1319 en la vista y en el header, y banner nuevo. "Actual" restaura los valores guardados.
function paintKumo(view, on) {
if (view.dataset.paperOriginal === undefined) {
view.dataset.paperOriginal = view.style.getPropertyValue('--paper');
}
view.style.setProperty('--paper', on ? KUMO_NUBES_PAPER : view.dataset.paperOriginal);
paintBody(on);
if (on) {
watchNubesImage(view);
} else {
stopNubesImage();
}
const image = view.querySelector('.kumo-cinema-image');
if (!image || !KUMO_NUBES_SRC.startsWith('https://')) {
return;
}
if (image.dataset.srcOriginal === undefined) {
image.dataset.srcOriginal = image.getAttribute('src') || '';
image.dataset.srcsetOriginal = image.getAttribute('srcset') || '';
image.dataset.altOriginal = image.alt;
}
if (on) {
image.removeAttribute('srcset');
image.src = KUMO_NUBES_SRC;
image.alt = 'KUMØ — Anime / Culture / Wear';
} else {
image.src = image.dataset.srcOriginal;
if (image.dataset.srcsetOriginal) {
image.setAttribute('srcset', image.dataset.srcsetOriginal);
}
image.alt = image.dataset.altOriginal;
}
}
function stopNubesImage() {
if (nubesImageObserver) {
nubesImageObserver.disconnect();
}
nubesImageObserver = null;
nubesImageView = null;
}
function watchNubesImage(view) {
const art = view.querySelector('.hero-art');
if (!art || nubesImageView === view) {
return;
}
stopNubesImage();
nubesImageView = view;
// renderHero reemplaza la imagen tambien al terminar de cargar el catalogo.
// Vigila solo los hijos del banner: cambiar src no vuelve a disparar este observador.
nubesImageObserver = new MutationObserver(() => {
const current = target();
if (current && current.view === view && view.hasAttribute('data-mock-nubes')) {
paintKumo(view, true);
}
});
nubesImageObserver.observe(art, {childList: true});
}
function paintBody(on) {
const style = document.body.style;
if (on) {
if (bodyPaper === null) {
bodyPaper = style.getPropertyValue('--paper');
}
style.setProperty('--paper', KUMO_NUBES_PAPER);
document.body.dataset.mockNubes = '';
} else if (bodyPaper !== null) {
if (style.getPropertyValue('--paper') === KUMO_NUBES_PAPER) {
style.setProperty('--paper', bodyPaper);
}
bodyPaper = null;
delete document.body.dataset.mockNubes;
}
}
function sync(on) {
actual.setAttribute('aria-pressed', String(!on));
mock.setAttribute('aria-pressed', String(on));
}
// Banner afiche del mock 90 Crema. Se agrega una vez por vista; el CSS lo muestra solo con data-mock-crema.
function ensureBanner(view) {
const hero = view.querySelector('.universe-hero');
const copy = view.querySelector('.hero-copy');
if (!hero || !copy || copy.querySelector('.mock-crema-copy')) {
return;
}
const box = document.createElement('div');
box.className = 'mock-crema-copy';
box.innerHTML = '<i class="mcc-bar" aria-hidden="true"></i><p class="mcc-kicker">FÚTBOL / ARCHIVO</p>'
+ '<p class="mcc-title" role="heading" aria-level="1"><span>90</span><span>MINUTOS</span></p>'
+ '<p class="mcc-sub">ARG / CLÁSICOS</p><a class="mcc-cta" href="#universe-catalog">EXPLORAR ↗</a>';
box.querySelector('.mcc-cta').addEventListener('click', event => {
event.preventDefault();
view.querySelector('.universe-catalog').scrollIntoView({behavior: 'auto', block: 'start'});
});
copy.append(box);
const stars = document.createElement('span');
stars.className = 'mcc-deco mcc-stars';
stars.setAttribute('aria-hidden', 'true');
stars.textContent = '★★★';
const stripes = document.createElement('span');
stripes.className = 'mcc-deco mcc-stripes';
stripes.setAttribute('aria-hidden', 'true');
hero.append(stars, stripes);
}
// KUMØ Nubes: la marca va como texto (misma tipografia que Actual) sobre la imagen sin letras. Una vez por vista.
function ensureNubesCopy(view) {
const copy = view.querySelector('.hero-copy');
if (!copy || copy.querySelector('.mock-nubes-copy')) {
return;
}
const box = document.createElement('div');
box.className = 'mock-nubes-copy';
box.innerHTML = '<p class="mnc-kanji" lang="ja">雲</p>'
+ '<p class="mnc-title" role="heading" aria-level="1">KUMØ</p>'
+ '<p class="mnc-sub">ANIME / CULTURE / WEAR</p>';
copy.insertBefore(box, copy.querySelector('.hero-cta'));
}
function update() {
const current = target();
bar.hidden = !current;
if (!current || current.key !== 'kumo') {
stopNubesImage();
paintBody(false);
}
if (!current) {
return;
}
const definition = mocks[current.key];
bar.setAttribute('aria-label', 'Comparar diseños de ' + definition.title.replace('DISEÑO ', ''));
title.textContent = definition.title;
mock.textContent = definition.label;
if (current.key === 'football') {
ensureBanner(current.view);
} else {
ensureNubesCopy(current.view);
if (selected(current.key) || current.view.hasAttribute(definition.attribute)) {
// Reaplica siempre: al cargar con ?mock= la imagen puede no existir todavia en el primer aviso.
setMock(current, selected(current.key));
}
}
sync(current.view.hasAttribute(definition.attribute) || selected(current.key));
}
function init() {
const main = document.getElementById('MainContent');
if (!main) {
return;
}
document.body.append(bar);
new MutationObserver(update).observe(main, {attributes: true, attributeFilter: ['data-universe-preview'], childList: true});
update();
}
if (document.readyState === 'loading') {
document.addEventListener('DOMContentLoaded', init);
} else {
init();
}
})();
}
