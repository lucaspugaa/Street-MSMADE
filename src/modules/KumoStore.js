import { Universe } from '../core/Universe.js';

// Universo KUMØ en la categoría (theme/blocks/kumo-store.tpl).
// Sube la sección al inicio de #MainContent, marca el listado como #kumo-catalogo,
// manda el outro al final y los links a #kumo-catalogo hacen scroll suave.
export class KumoStore extends Universe {
  render() {
    this.main = document.getElementById('MainContent');
    const section = this.el.closest('.ns-section');
    if (!this.main || !section) return;

    if (this.main.firstElementChild !== section) {
      this.main.insertBefore(section, this.main.firstElementChild);
    }

    this.grid = this.main.querySelector('section.section-main-products-grid');
    if (this.grid) this.grid.id = 'kumo-catalogo';

    const outro = this.el.querySelector('.kumo-outro');
    if (outro) this.main.appendChild(outro);
    this.ready = true;
  }

  bind() {
    if (!this.ready) return;

    this.el.querySelectorAll('a[href="#kumo-catalogo"]').forEach(link => {
      link.addEventListener('click', event => {
        if (!this.grid) return;
        event.preventDefault();
        this.grid.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });
    });
  }
}
