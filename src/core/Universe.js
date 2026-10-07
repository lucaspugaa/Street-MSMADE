export class Universe {
  constructor(el) {
    if (new.target === Universe) throw new Error('Universe es abstracta');
    this.el = el;
    this.config = JSON.parse(el.dataset.config || '{}');
  }
  init()    { this.render(); this.bind(); }
  render()  {}   // obligatorio en cada módulo
  bind()    {}   // eventos
  destroy() {}
}
