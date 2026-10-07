import { Universe } from '../core/Universe.js';
import { run } from './legacy/store-theme.js';

// Global (antes en el footer): paletas por universo, menú de universos, premios del carrito y enlaces.
// Por ahora ejecuta el script original tal cual (src/modules/legacy/store-theme.js).
export class StoreTheme extends Universe {
  render() {
    run();
  }
}
