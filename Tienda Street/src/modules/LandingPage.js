import { Universe } from '../core/Universe.js';
import { run } from './legacy/landing-page.js';

// Home: carruseles de más vendidos por universo, previews de universos, beneficios y confianza de compra.
// Por ahora ejecuta el script original tal cual (src/modules/legacy/landing-page.js).
export class LandingPage extends Universe {
  render() {
    run(this.el);
  }
}
