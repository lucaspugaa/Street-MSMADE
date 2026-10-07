import { Universe } from '../core/Universe.js';

// Universo en la ficha de producto (theme/blocks/product-universe.tpl).
// La franja "Volver a …" va al inicio de #MainContent y la guía de compra justo después del producto.
export class ProductUniverse extends Universe {
  render() {
    const main = document.getElementById('MainContent');
    if (!main) return;

    main.insertBefore(this.el, main.firstElementChild);

    const product = main.querySelector('.section-main-product');
    const guide = main.querySelector('.product-universe-guide');
    if (product && guide) product.insertAdjacentElement('afterend', guide);
  }
}
