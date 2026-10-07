import { Universe } from '../core/Universe.js';
import { run } from './legacy/design-mocks.js';

// Global (antes en el footer): comparador de diseños, solo activo en el editor/preview de TEST.
// Por ahora ejecuta el script original tal cual (src/modules/legacy/design-mocks.js).
export class DesignMocks extends Universe {
  render() {
    run();
  }
}
