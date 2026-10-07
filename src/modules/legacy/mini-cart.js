// Copia fiel del <script> del bloque de código original (footer · code_9p7a).
// Se ejecuta tal cual desde su módulo; el refactor a clases queda para cuando haya preview para verificar.
export function run() {
(function () {
'use strict';
if (window.streetMiniCart) {
return;
}
window.streetMiniCart = true;
// Picks a small rendition from the native (possibly lazy) cart thumbnail.
function thumbnail(image) {
if (!image) {
return '';
}
const set = image.getAttribute('srcset') || image.getAttribute('data-srcset') || '';
const entries = set.split(',').map(entry => entry.trim().split(/\s+/)[0]).filter(Boolean);
return entries.find(url => /-(240|320)-0\./.test(url)) || entries[0] || image.currentSrc || image.getAttribute('src') || '';
}
function init() {
const modal = document.getElementById('modal-cart');
if (!modal || document.querySelector('.street-mini-cart')) {
return;
}
const chip = document.createElement('button');
chip.type = 'button';
chip.className = 'street-mini-cart';
chip.hidden = true;
const image = document.createElement('img');
image.alt = '';
image.width = 64;
image.height = 64;
image.decoding = 'async';
const count = document.createElement('span');
count.className = 'street-mini-cart-count';
count.setAttribute('aria-hidden', 'true');
chip.append(image, count);
document.body.append(chip);
chip.addEventListener('click', () => {
const opener = document.querySelector('.js-modal-open-private[data-target="#modal-cart"], [data-target="#modal-cart"]:not(.js-modal-close-private)');
if (opener) {
opener.click();
}
});
function sync() {
const items = modal.querySelectorAll('.js-cart-item');
chip.hidden = !items.length || modal.classList.contains('modal-show');
if (!items.length) {
return;
}
// AJAX prepends new rows; the lowest line id is the first product chosen.
const first = Array.from(items).reduce((a, b) => Number(b.dataset.itemId) < Number(a.dataset.itemId) ? b : a);
const url = thumbnail(first.querySelector('img'));
if (url && image.getAttribute('src') !== url) {
image.src = url;
}
let units = 0;
items.forEach(item => {
units += Number(item.querySelector('.js-cart-quantity-input')?.value) || 1;
});
const badge = Number(document.querySelector('.js-cart-widget-amount')?.textContent);
const total = badge > 0 ? badge : units;
count.textContent = total;
const name = first.querySelector('[data-component="name.short-name"]')?.textContent.trim() || 'Producto';
chip.setAttribute('aria-label', 'Abrir carrito: ' + name + (total > 1 ? ' y ' + (total - 1) + ' más' : ''));
}
let timer = 0;
const schedule = () => {
clearTimeout(timer);
timer = setTimeout(sync, 60);
};
new MutationObserver(schedule).observe(modal, {attributes: true, attributeFilter: ['class'], childList: true, subtree: true});
document.querySelectorAll('.js-cart-widget-amount').forEach(node => new MutationObserver(schedule).observe(node, {childList: true, characterData: true, subtree: true}));
sync();
}
if (document.readyState === 'loading') {
document.addEventListener('DOMContentLoaded', init, {once: true});
} else {
init();
}
})();
}
