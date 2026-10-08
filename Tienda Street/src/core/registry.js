import { DesignMocks } from '../modules/DesignMocks.js';
import { KumoStore } from '../modules/KumoStore.js';
import { LandingPage } from '../modules/LandingPage.js';
import { MiniCart } from '../modules/MiniCart.js';
import { MocksModified } from '../modules/MocksModified.js';
import { ProductUniverse } from '../modules/ProductUniverse.js';
import { StoreTheme } from '../modules/StoreTheme.js';
import { UniverseHero } from '../modules/UniverseHero.js';

// data-module="<Nombre>" en el Twig → clase que lo maneja.
// main.js los inicializa en orden de documento (mismo orden en que corrían los scripts inline originales).
export const registry = {
  DesignMocks,
  KumoStore,
  LandingPage,
  MiniCart,
  MocksModified,
  ProductUniverse,
  StoreTheme,
  UniverseHero,
};
