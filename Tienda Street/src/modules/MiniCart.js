import { Universe } from '../core/Universe.js';
import { run } from './legacy/mini-cart.js';

// Global (antes en el footer): acceso flotante al carrito en mobile y botón "Eliminar" en el carrito.
// Por ahora ejecuta el script original tal cual (src/modules/legacy/mini-cart.js).
export class MiniCart extends Universe {
  render() {
    run();
  }
}
