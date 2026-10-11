import { detectImageFormat } from '../public/image-format.js';
import sharp from 'sharp';

export const LIMITS = {
  ancho: [32, 4096, true],
  alto: [32, 4096, true],
  escala: [0.01, 1],
  posicion_vertical: [0, 1],
  tolerancia: [0, 255],
  recortar_borde: [0, 20, true],
  rellenar_bordes: [0, 40, true],
  suavizar_contorno: [0, 20],
  borde_suave: [0, 100],
};

const SHADOW_LIMITS = {
  opacidad: [0, 1],
  desenfoque: [0, 200],
  x: [-4096, 4096],
  y: [-4096, 4096],
};
const COLOR = /^#[\da-f]{6}$/i;

export function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function number(value, key, [min, max, integer]) {
  if (typeof value !== 'number' || !Number.isFinite(value)
      || value < min || value > max || (integer && !Number.isInteger(value))) {
    throw new Error(`${key}: usá un número ${integer ? 'entero ' : ''}entre ${min} y ${max}.`);
  }
}

export function validateOptions(options) {
  if (!isObject(options)) {
    throw new Error('opciones tiene que ser un objeto.');
  }

  for (const [key, value] of Object.entries(options)) {
    if (Object.hasOwn(LIMITS, key)) {
      number(value, key, LIMITS[key]);
    } else if (key === 'recorte') {
      if (!['preciso', 'rapido'].includes(value)) {
        throw new Error('recorte: usá "preciso" o "rapido".');
      }
    } else if (key === 'quitar_huecos' || key === 'sombra_original') {
      if (typeof value !== 'boolean') {
        throw new Error(`${key}: usá true o false.`);
      }
    } else if (key === 'sombra') {
      if (value === false) {
        continue;
      }
      if (!isObject(value)) {
        throw new Error('sombra: usá un objeto o false.');
      }
      for (const [name, setting] of Object.entries(value)) {
        if (!Object.hasOwn(SHADOW_LIMITS, name)) {
          throw new Error(`Opción de sombra desconocida: ${name}.`);
        }
        number(setting, `sombra.${name}`, SHADOW_LIMITS[name]);
      }
    } else if (key === 'fondo') {
      const solid = typeof value === 'string' && COLOR.test(value);
      const gradient = isObject(value) && Object.keys(value).length === 1
        && Array.isArray(value.degradado) && value.degradado.length === 2
        && value.degradado.every(color => typeof color === 'string' && COLOR.test(color));
      if (!solid && !gradient) {
        throw new Error('fondo: usá un color #rrggbb o { "degradado": ["#rrggbb", "#rrggbb"] }.');
      }
    } else {
      throw new Error(`Opción desconocida: ${key}.`);
    }
  }

  return options;
}

export async function validateImage(bytes) {
  const format = detectImageFormat(bytes);
  if (!format) throw new Error('Elegí una imagen PNG, JPEG o WebP.');
  let metadata;
  try {
    metadata = await sharp(bytes, { limitInputPixels: 40_000_000 }).metadata();
  } catch {
    throw new Error('No se pudo leer la imagen. Elegí un PNG, JPEG o WebP válido de hasta 40 megapíxeles.');
  }

  if (metadata.format !== format
      || (metadata.pages ?? 1) !== 1 || !metadata.width || !metadata.height
      || metadata.width * metadata.height > 40_000_000) {
    throw new Error('Elegí una sola imagen PNG, JPEG o WebP, sin animación y de hasta 40 megapíxeles.');
  }

  return bytes;
}

export async function decodeImage(dataURL) {
  if (typeof dataURL !== 'string') {
    throw new Error('La imagen tiene que ser un dataURL.');
  }
  const match = /^data:[^,]*;base64,([A-Za-z0-9+/]+={0,2})$/.exec(dataURL);
  if (!match || match[1].length % 4 !== 0) {
    throw new Error('Usá un dataURL base64 de una imagen PNG, JPEG o WebP.');
  }

  const bytes = Buffer.from(match[1], 'base64');
  if (bytes.toString('base64') !== match[1]) {
    throw new Error('El contenido base64 de la imagen no es válido.');
  }
  return validateImage(bytes);
}
