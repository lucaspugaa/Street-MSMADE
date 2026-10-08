import { Universe } from '../core/Universe.js';

const STORAGE_KEY = 'street-mocks-modified';
const ATTRIBUTES = ['src', 'srcset', 'data-src', 'data-srcset', 'href', 'type'];
const MEDIA_SELECTOR = 'img, source, a';
const ORIGINAL_ATTRIBUTE = 'data-mocks-modified-original';

export class MocksModified extends Universe {
  init() {
    const requested = new URLSearchParams(window.location.search).get('mocks');
    let remembered = null;

    try {
      if (requested === '0') {
        sessionStorage.removeItem(STORAGE_KEY);
      } else if (requested) {
        sessionStorage.setItem(STORAGE_KEY, requested);
      } else {
        remembered = sessionStorage.getItem(STORAGE_KEY);
      }
    } catch {
      // El preview también funciona si el navegador bloquea sessionStorage.
    }

    this.preference = requested === '0' ? null : requested || remembered;
    if (!this.preference) {
      return;
    }

    this.gallery = document.querySelector('#single-product .js-product-images');
    if (!this.gallery) {
      return;
    }

    this.observer = new MutationObserver(() => this.refresh());
    this.refresh();
  }

  imageKey(value) {
    // El nombre base conserva guiones; solo se quitan hash y dimensiones del CDN.
    const urls = (value || '').split(',').map(candidate => candidate.trim().split(/\s+/)[0]);

    for (const url of urls) {
      const match = /\/products\/([^/?#]+)-[a-f0-9]{32}-\d+(?:-\d+)?\.webp(?:[?#]|$)/i.exec(url);
      if (match && Object.hasOwn(this.config.images, match[1])) {
        return match[1];
      }
    }

    return null;
  }

  readOriginal(node) {
    const saved = node.getAttribute(ORIGINAL_ATTRIBUTE);
    return saved ? JSON.parse(saved) : null;
  }

  mediaKey(node) {
    for (const name of ATTRIBUTES) {
      const key = this.imageKey(node.getAttribute(name));
      if (key) {
        return key;
      }
    }

    return this.readOriginal(node)?.key || null;
  }

  refresh() {
    // Desconectar durante nuestras escrituras evita ciclos de observer.
    this.observer.disconnect();
    const nodes = [...this.gallery.querySelectorAll(MEDIA_SELECTOR)];
    const keys = new Set(nodes.map(node => this.mediaKey(node)).filter(Boolean));
    this.sets = Object.keys(this.config.labels).filter(set =>
      [...keys].some(key => this.config.images[key]?.[set])
    );
    this.selected = this.preference === '1' ? this.sets[0] || 'original' : this.preference;

    if (!this.sets.includes(this.selected)) {
      this.selected = 'original';
    }

    this.render();

    for (const node of nodes) {
      const key = this.mediaKey(node);
      const mock = this.config.images[key]?.[this.selected];

      if (mock) {
        this.replace(node, key, mock);
      } else {
        this.restore(node);
      }
    }

    this.observer.observe(this.gallery, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ATTRIBUTES,
    });
  }

  replace(node, key, mock) {
    let original = this.readOriginal(node);

    if (original && original.key !== key) {
      this.restore(node);
      original = null;
    }

    if (!original) {
      original = {
        key,
        attributes: Object.fromEntries(ATTRIBUTES.map(name => [name, node.getAttribute(name)])),
      };
      node.setAttribute(ORIGINAL_ATTRIBUTE, JSON.stringify(original));
    }

    for (const name of ATTRIBUTES) {
      if (name === 'type') {
        continue;
      }

      const current = node.getAttribute(name);
      const previousMock = Object.values(this.config.images[original.key]).includes(current);
      if (this.imageKey(current) || this.imageKey(original.attributes[name]) || previousMock) {
        node.setAttribute(name, mock);
      }
    }

    // Un source AVIF debe anunciar el formato WebP del mock.
    if (node.tagName === 'SOURCE' && node.hasAttribute('type')) {
      node.setAttribute('type', 'image/webp');
    }
  }

  restore(node) {
    const original = this.readOriginal(node);
    if (!original) {
      return;
    }

    // Lazy puede haber promovido los data-* a src/srcset mientras mostraba el mock.
    // Restaurar entonces la URL real, en vez del GIF inicial ya marcado como cargado.
    const loaded = node.tagName === 'IMG' && node.getAttribute('src') !== original.attributes.src;
    const responsiveLoaded = node.hasAttribute('srcset') && original.attributes.srcset === null;

    for (const [name, value] of Object.entries(original.attributes)) {
      if (value === null) {
        node.removeAttribute(name);
      } else {
        node.setAttribute(name, value);
      }
    }

    if (loaded && original.attributes['data-src']) {
      node.setAttribute('src', original.attributes['data-src']);
    }

    if ((loaded || responsiveLoaded) && original.attributes['data-srcset']) {
      node.setAttribute('srcset', original.attributes['data-srcset']);
    }

    node.removeAttribute(ORIGINAL_ATTRIBUTE);
  }

  render() {
    if (!this.sets.length) {
      this.control?.remove();
      this.control = null;
      return;
    }

    if (!this.control) {
      this.control = document.createElement('div');
      this.control.className = 'mocks-modified';
      this.control.setAttribute('role', 'group');
      this.control.setAttribute('aria-label', 'Mocks: fondo de las imágenes del producto');
      this.el.append(this.control);
      this.bind();
    }

    const signature = this.sets.join('|');
    if (this.control.dataset.sets !== signature) {
      this.control.replaceChildren();
      const title = document.createElement('span');
      title.textContent = 'Mocks';
      this.control.append(title);

      for (const set of ['original', ...this.sets]) {
        const button = document.createElement('button');
        button.type = 'button';
        button.dataset.set = set;
        button.textContent = set === 'original' ? 'Original' : this.config.labels[set];
        this.control.append(button);
      }

      this.control.dataset.sets = signature;
    }

    for (const button of this.control.querySelectorAll('button')) {
      button.setAttribute('aria-pressed', String(button.dataset.set === this.selected));
    }

    this.position();
  }

  bind() {
    this.control.addEventListener('click', event => {
      const button = event.target.closest('button[data-set]');
      if (!button) {
        return;
      }

      this.preference = button.dataset.set;
      try {
        sessionStorage.setItem(STORAGE_KEY, this.preference);
      } catch {
        // La selección actual no depende del almacenamiento.
      }

      this.refresh();
    });

    if (!this.onPosition) {
      this.onPosition = () => this.position();
      window.addEventListener('resize', this.onPosition);
      window.addEventListener('scroll', this.onPosition, { passive: true });
      this.header = document.querySelector('.js-header');
      this.headerObserver = new ResizeObserver(this.onPosition);
      if (this.header) {
        this.headerObserver.observe(this.header);
      }
    }
  }

  position() {
    if (!this.control) {
      return;
    }

    const bottom = this.header?.getBoundingClientRect().bottom || 0;
    this.control.style.top = `${Math.max(8, bottom + 8)}px`;
  }

  destroy() {
    this.observer?.disconnect();
    this.headerObserver?.disconnect();
    window.removeEventListener('resize', this.onPosition);
    window.removeEventListener('scroll', this.onPosition);
    this.gallery?.querySelectorAll(`[${ORIGINAL_ATTRIBUTE}]`).forEach(node => this.restore(node));
    this.control?.remove();
  }
}
