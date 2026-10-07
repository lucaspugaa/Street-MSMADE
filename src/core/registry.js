import { KumoStore } from '../modules/KumoStore.js';
import { ProductUniverse } from '../modules/ProductUniverse.js';
import { UniverseHero } from '../modules/UniverseHero.js';

// data-module="<Nombre>" en el Twig → clase que lo maneja.
export const registry = {
  KumoStore,
  ProductUniverse,
  UniverseHero,
};
