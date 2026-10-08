import { Universe } from '../core/Universe.js';

const STORAGE_KEY = 'street-mocks-modified';
const CARD = '.js-product-item-private[data-product-type="list"]';
const COVER = '[data-mocks-modified-cover]';
const CARD_SLIDER = '.js-product-item-slider-container-private';
const IMAGE_ATTRIBUTES = ['src', 'srcset', 'data-src', 'data-srcset'];

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
      // El preview funciona también con almacenamiento bloqueado.
    }

    this.preference = requested === '0' ? null : requested || remembered;
    this.main = document.getElementById('MainContent');
    if (!this.preference || !this.main || document.body.classList.contains('template-home')) {
      return;
    }

    this.states = new Map();
    this.observer = new MutationObserver(() => this.refresh());
    this.onClick = event => this.navigate(event);
    this.main.addEventListener('click', this.onClick);
    this.refresh();
  }

  handle(href) {
    try {
      const url = new URL(href, window.location.href);
      if (url.origin !== window.location.origin) {
        return null;
      }

      return /^\/productos\/([^/]+)\/?$/.exec(url.pathname)?.[1] || null;
    } catch {
      return null;
    }
  }

  targets() {
    const targets = [];
    const gallery = this.main.querySelector('#single-product .js-product-images');
    if (gallery) {
      targets.push({ root: gallery, handle: this.handle(window.location.href), product: true });
    }

    for (const card of this.main.querySelectorAll(CARD)) {
      const link = card.querySelector('.js-product-item-image-link-private, .product-item-link');
      const handle = link && this.handle(link.href);
      targets.push({ root: card, handle, product: false });
    }

    return targets;
  }

  refresh() {
    this.observer.disconnect();
    const targets = this.targets();
    this.sets = Object.keys(this.config.labels).filter(set =>
      targets.some(target => this.config.products[target.handle]?.[set])
    );
    this.selected = this.preference === '1' ? this.sets[0] || 'original' : this.preference;
    if (!this.sets.includes(this.selected)) {
      this.selected = 'original';
    }

    this.render();
    const present = new Set(targets.map(target => target.root));
    for (const [root, state] of this.states) {
      const target = targets.find(target => target.root === root);
      const mock = target && this.config.products[target.handle]?.[this.selected];
      if (!present.has(root) || !mock || target.handle !== state.handle) {
        this.restore(state);
        this.states.delete(root);
      }
    }

    for (const target of targets) {
      const mock = this.config.products[target.handle]?.[this.selected];
      if (!mock) {
        continue;
      }

      let state = this.states.get(target.root);
      if (!state) {
        state = { ...target, saved: new Map(), sliders: [], replacements: [] };
        this.states.set(target.root, state);
      }

      this.apply(state, mock);
    }

    this.observer.observe(this.main, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: [...IMAGE_ATTRIBUTES, 'href', 'class'],
    });
  }

  save(state, node, name) {
    let attributes = state.saved.get(node);
    if (!attributes) {
      attributes = new Map();
      state.saved.set(node, attributes);
    }

    if (!attributes.has(name)) {
      attributes.set(name, node.getAttribute(name));
    }
  }

  write(state, node, name, value) {
    this.save(state, node, name);
    if (node.getAttribute(name) !== String(value)) {
      node.setAttribute(name, value);
    }
  }

  mockImage(original, mock) {
    const img = original.cloneNode(false);
    img.removeAttribute('id');
    for (const name of IMAGE_ATTRIBUTES) {
      img.removeAttribute(name);
    }

    img.classList.remove('lazyload', 'lazyloading', 'swiper-lazy', 'swiper-lazy-loading', 'product-item-image-featured');
    img.classList.add('lazyloaded', 'swiper-lazy-loaded');
    img.setAttribute('src', mock);
    img.setAttribute('loading', 'eager');
    return img;
  }

  createSlide(first, mock, thumb) {
    const slide = document.createElement('div');
    slide.className = first.className;
    slide.classList.remove('swiper-slide-active', 'swiper-slide-next', 'swiper-slide-prev', 'swiper-slide-duplicate');
    slide.dataset.mocksModifiedCover = '';
    const original = first.querySelector('img');
    const link = first.querySelector('.js-product-slide-link, .js-product-thumb');
    const img = this.mockImage(original, mock);

    if (link) {
      const copy = link.cloneNode(false);
      copy.removeAttribute('id');
      copy.classList.remove('selected', 'is-active', 'js-product-thumb-modal');
      copy.removeAttribute('data-video_id');
      if (thumb) {
        copy.dataset.thumbLoop = '0';
      } else if (copy.tagName === 'A') {
        copy.href = mock;
      }

      copy.append(img);
      slide.append(copy);
    } else {
      slide.append(img);
    }

    if (!thumb) {
      slide.dataset.imagePosition = '0';
    }

    return slide;
  }

  addSlider(state, container, mock, thumb = false) {
    let slider = state.sliders.find(slider => slider.container === container);
    if (slider) {
      return slider;
    }

    const wrapper = container.querySelector('.swiper-wrapper');
    const first = wrapper && [...wrapper.children].find(slide =>
      !slide.matches('.swiper-slide-duplicate') && slide.querySelector('img')
    );
    if (!first) {
      return null;
    }

    if (state.product) {
      for (const link of state.root.querySelectorAll('.js-product-thumb')) {
        this.save(state, link, 'class');
      }
    }

    const cover = this.createSlide(first, mock, thumb);
    slider = {
      container, wrapper, cover, thumb,
      originalIndex: container.swiper?.realIndex ?? container.swiper?.activeIndex ?? 0,
      originalScroll: container.scrollLeft,
      index: 0, count: 0, synced: null,
    };
    state.sliders.push(slider);
    if (!thumb) {
      this.ensureControls(state, slider);
    }

    const swiper = container.swiper;
    if (swiper && !swiper.destroyed) {
      swiper.prependSlide(cover);
    } else {
      wrapper.prepend(cover);
    }

    return slider;
  }

  apply(state, mock) {
    const main = state.root.querySelector(state.product ? '.js-product-slider' : CARD_SLIDER);
    if (main) {
      this.addSlider(state, main, mock);
      if (state.product) {
        const thumbs = state.root.querySelector('.js-product-slider-thumbs');
        if (thumbs) {
          this.addSlider(state, thumbs, mock, true);
        }
      }
    } else if (!state.product) {
      const link = state.root.querySelector('.js-product-item-image-link-private');
      const original = link?.querySelector('img:not(.js-product-item-secondary-image-private)');
      if (original && !original.matches(COVER)) {
        const replaced = original.closest('picture') || original;
        const img = this.mockImage(original, mock);
        img.dataset.mocksModifiedCover = '';
        replaced.replaceWith(img);
        state.replacements.push({ original: replaced, cover: img });
      }
    }

    for (const cover of state.root.querySelectorAll(COVER)) {
      const img = cover.matches('img') ? cover : cover.querySelector('img');
      if (img.getAttribute('src') !== mock) {
        img.setAttribute('src', mock);
      }

      for (const name of ['srcset', 'data-src', 'data-srcset']) {
        if (img.hasAttribute(name)) {
          img.removeAttribute(name);
        }
      }

      const zoom = cover.querySelector('a[data-fancybox]');
      if (zoom && zoom.getAttribute('href') !== mock) {
        zoom.setAttribute('href', mock);
      }
    }

    for (const slider of state.sliders) {
      this.sync(state, slider);
    }
  }

  sync(state, slider) {
    const { container, wrapper, thumb } = slider;
    const slides = [...wrapper.children].filter(slide => !slide.matches('.swiper-slide-duplicate'));
    const swiper = container.swiper;
    const live = swiper && !swiper.destroyed;
    const changed = slider.count !== slides.length || slider.synced !== (live ? swiper : null);

    if (!thumb) {
      slides.forEach((slide, index) => {
        if (!slide.matches(COVER)) {
          this.write(state, slide, 'data-image-position', index);
        }
      });

      for (const name of ['data-product-images-amount', 'data-images-count', 'data-initial-slides', 'data-max-slides']) {
        if (container.hasAttribute(name)) {
          this.save(state, container, name);
          this.write(state, container, name, Number(state.saved.get(container).get(name)) + 1);
        }
      }

      if (container.hasAttribute('data-append-images')) {
        this.save(state, container, 'data-append-images');
        const pending = JSON.parse(state.saved.get(container).get('data-append-images'));
        this.write(state, container, 'data-append-images', JSON.stringify(
          pending.map(image => ({ ...image, index: image.index + 1 }))
        ));
      }
    } else {
      slides.forEach((slide, index) => {
        const link = slide.querySelector('.js-product-thumb');
        if (link && !slide.matches(COVER)) {
          this.write(state, link, 'data-thumb-loop', index);
        }
      });
    }

    if (!changed) {
      return;
    }

    slider.count = slides.length;
    slider.synced = live ? swiper : null;
    if (live) {
      container.classList.remove('mocks-modified-fallback');
      swiper.update();
      swiper.pagination?.render();
      swiper.pagination?.update();
      swiper.navigation?.update();
      swiper.slideTo(slider.index, 0);
      if (slider.boundSwiper !== swiper) {
        if (slider.boundSwiper && !slider.boundSwiper.destroyed) {
          slider.boundSwiper.off('slideChange', slider.onChange);
        }

        slider.boundSwiper = swiper;
        slider.onChange = () => this.updateSelection(state, slider, swiper.activeIndex);
        swiper.on('slideChange', slider.onChange);
      }
    } else if (!thumb) {
      container.classList.add('mocks-modified-fallback');
      if (!slider.onScroll) {
        slider.onScroll = () => {
          if (!container.swiper && container.clientWidth) {
            this.updateSelection(state, slider, Math.round(container.scrollLeft / container.clientWidth));
          }
        };
        container.addEventListener('scroll', slider.onScroll, { passive: true });
      }
    }

    if (!thumb) {
      this.ensureControls(state, slider);
      this.updateSelection(state, slider, slider.index);
    }
  }

  ensureControls(state, slider) {
    const root = state.product ? state.root : slider.container;
    slider.pagination = slider.pagination?.isConnected ? slider.pagination : root.querySelector(state.product
      ? '.js-product-slider-pagination' : '.js-product-item-slider-pagination-private');
    if (!slider.pagination) {
      slider.pagination = document.createElement('div');
      slider.pagination.dataset.mocksModifiedOwned = '';
      slider.container.after(slider.pagination);
    }

    slider.originalPagination = slider.originalPagination ?? slider.pagination.innerHTML;
    const prev = root.querySelector('.js-product-slider-prev, .js-product-item-prev-container-private');
    if (!prev && !slider.controls) {
      slider.controls = document.createElement('div');
      slider.controls.dataset.mocksModifiedOwned = '';
      slider.controls.className = 'mocks-modified-navigation';
      for (const [direction, label] of [['prev', 'Imagen anterior'], ['next', 'Imagen siguiente']]) {
        const button = document.createElement('button');
        button.type = 'button';
        button.dataset.mocksModifiedDirection = direction;
        button.setAttribute('aria-label', label);
        button.textContent = direction === 'prev' ? '‹' : '›';
        slider.controls.append(button);
      }

      slider.container.after(slider.controls);
    }
  }

  updateSelection(state, slider, index) {
    slider.index = index;
    if (slider.thumb) {
      return;
    }

    if (!slider.container.swiper || slider.pagination?.hasAttribute('data-mocks-modified-owned')) {
      if (slider.pagination) {
        slider.pagination.textContent = `${index + 1} / ${slider.count}`;
      }
    }

    if (state.product) {
      const thumbs = state.root.querySelectorAll('.js-product-thumb');
      thumbs.forEach((thumb, position) => {
        this.save(state, thumb, 'class');
        thumb.classList.toggle('selected', position === index);
        thumb.classList.toggle('is-active', position === index);
      });
    }
  }

  navigate(event) {
    for (const state of this.states.values()) {
      if (!state.root.contains(event.target)) {
        continue;
      }

      const slider = state.sliders.find(slider => !slider.thumb);
      if (!slider) {
        continue;
      }

      const button = event.target.closest('[data-mocks-modified-direction], .js-product-slider-prev, .js-product-slider-next, .js-product-item-prev-container-private, .js-product-item-next-container-private');
      const thumb = event.target.closest('.js-product-thumb');
      const owned = button?.hasAttribute('data-mocks-modified-direction');
      if ((!button && !thumb) || (slider.container.swiper && !owned)) {
        return;
      }

      event.preventDefault();
      const previous = button?.matches('[data-mocks-modified-direction="prev"], .js-product-slider-prev, .js-product-item-prev-container-private');
      const index = thumb ? Number(thumb.dataset.thumbLoop) : slider.index + (previous ? -1 : 1);
      const bounded = Math.max(0, Math.min(index, slider.count - 1));
      if (slider.container.swiper) {
        slider.container.swiper.slideTo(bounded);
      } else {
        slider.container.scrollTo({ left: bounded * slider.container.clientWidth });
      }

      this.updateSelection(state, slider, bounded);
      return;
    }
  }

  restore(state) {
    for (const slider of state.sliders) {
      slider.container.classList.remove('mocks-modified-fallback');
      const swiper = slider.container.swiper;
      if (swiper && !swiper.destroyed) {
        if (slider.onChange) {
          swiper.off('slideChange', slider.onChange);
        }

        const slides = [...slider.wrapper.children].filter(slide => !slide.matches('.swiper-slide-duplicate'));
        const index = slides.findIndex(slide => slide.matches(COVER));
        if (index >= 0) {
          swiper.removeSlide(index);
        }

        swiper.update();
        swiper.pagination?.render();
        swiper.pagination?.update();
        swiper.navigation?.update();
        swiper.slideTo(slider.originalIndex, 0);
      } else {
        slider.cover.remove();
        slider.container.scrollLeft = slider.originalScroll;
      }

      slider.container.removeEventListener('scroll', slider.onScroll);
      slider.controls?.remove();
      if (slider.pagination?.hasAttribute('data-mocks-modified-owned')) {
        slider.pagination.remove();
      } else if (slider.pagination && slider.originalPagination !== undefined && (!swiper || swiper.destroyed)) {
        slider.pagination.innerHTML = slider.originalPagination;
      }
    }

    for (const replacement of state.replacements) {
      replacement.cover.replaceWith(replacement.original);
    }

    for (const [node, attributes] of state.saved) {
      for (const [name, value] of attributes) {
        if (value === null) {
          node.removeAttribute(name);
        } else {
          node.setAttribute(name, value);
        }
      }
    }
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
      this.control.setAttribute('aria-label', 'Mocks: portada de productos');
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
    this.main?.removeEventListener('click', this.onClick);
    for (const state of this.states?.values() || []) {
      this.restore(state);
    }

    this.states?.clear();
    this.control?.remove();
  }
}
