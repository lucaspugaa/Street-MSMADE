import { Universe } from '../core/Universe.js';

// Hero de universo en la categoría (theme/blocks/universe-hero.tpl).
// La sección custom va última en la plantilla: se sube al inicio de #MainContent,
// se marca el listado como #universo-productos y el CTA hace scroll suave hasta ahí.
export class UniverseHero extends Universe {
  render() {
    this.main = document.getElementById('MainContent');
    if (!this.main) return;

    this.section = this.el.closest('.ns-section');
    if (this.section && this.main.firstElementChild !== this.section) {
      this.main.insertBefore(this.section, this.main.firstElementChild);
    }

    this.target = Array.from(this.main.children).find(
      element => element !== this.section && element.querySelector('a[href*="/productos/"]'),
    );
    if (this.target) this.target.id = 'universo-productos';
  }

  bind() {
    if (!this.main) return;

    this.el.querySelector('.universe-cta')?.addEventListener('click', event => {
      if (!this.target) return;
      event.preventDefault();
      this.target.scrollIntoView({ behavior: 'smooth' });
    });
  }
}
