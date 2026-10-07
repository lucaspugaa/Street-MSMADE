import { registry } from './core/registry.js';

function init() {
  document.querySelectorAll('[data-module]').forEach(el => {
    const Mod = registry[el.dataset.module];

    if (Mod) {
      try {
        new Mod(el).init();
      } catch (error) {
        console.error(`Error al iniciar el módulo ${el.dataset.module}:`, error);
      }
    }
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init, { once: true });
} else {
  init();
}
