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

// app.js se carga al final del <body> (theme/layouts/layout.tpl): el contenido ya está en el DOM,
// así que se inicializa enseguida, como los scripts inline originales (sin esperar DOMContentLoaded).
if (document.body) {
  init();
} else {
  document.addEventListener('DOMContentLoaded', init, { once: true });
}
