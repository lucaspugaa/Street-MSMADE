// Recorta la prenda de un mockup con fondo liso y la compone sobre un fondo nuevo.
// Copia del núcleo de Tienda Street/scripts/mocks/generar.mjs (npm run mocks:generar).
import sharp from 'sharp';
import { colorDistances, refineEdges } from './matting.mjs';
// Ojo: en sharp, erode() agranda las zonas blancas de una máscara y dilate() las achica
// (la morfología de libvips toma el negro como figura). Acá: erode = agrandar, dilate = achicar.
import { readFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';

// Modelo local de recorte (modo "preciso"): se carga recién cuando se usa. No redibuja la imagen,
// solo decide qué píxeles son prenda; los colores salen de la foto original.
let removeBackground;
async function modelMask(pngBytes) {
  const name = '@imgly/background-removal-node';
  if (!removeBackground) {
    try {
      ({ removeBackground } = await import(name));
    } catch {
      throw new Error('falta el modelo de recorte preciso: ejecutá npm install en ImageGenerator, o usá el recorte rápido');
    }
  }
  const dist = dirname(createRequire(import.meta.url).resolve(name));
  const blob = await removeBackground(new Blob([pngBytes], { type: 'image/png' }), {
    publicPath: `${pathToFileURL(join(dist, '/')).href}`,
    model: 'medium',
    output: { format: 'image/png' },
  });
  return sharp(Buffer.from(await blob.arrayBuffer())).ensureAlpha().extractChannel(3).raw().toBuffer({ resolveWithObject: true });
}

export const DEFAULTS = {
  fondo: '#1c1c1c',
  ancho: 1200,
  alto: 1500,
  escala: 0.78,
  posicion_vertical: 0.5,
  recorte: 'preciso',
  tolerancia: 8,
  recortar_borde: 1,
  rellenar_bordes: 8,
  suavizar_contorno: 3,
  borde_suave: 0.6,
  quitar_huecos: false,
  sombra_original: true,
  sombra: { opacidad: 0.45, desenfoque: 22, x: 0, y: 16 },
};

export function merge(...layers) {
  const result = { ...DEFAULTS, sombra: { ...DEFAULTS.sombra } };
  for (const layer of layers.filter(Boolean)) {
    for (const [key, value] of Object.entries(layer)) {
      result[key] = key === 'sombra' && value ? { ...result.sombra, ...value } : value;
    }
  }
  return result;
}


// Interpola la iluminación de los cuatro bordes sin muestrear la prenda.
function backgroundModel(data, width, height) {
  const profile = indices => indices.map((_, position) => {
    const samples = indices.slice(Math.max(0, position - 16), position + 17);
    return [0, 1, 2].map(channel => {
      const values = samples.map(i => data[i * 4 + channel]).sort((a, b) => a - b);
      return values[values.length >> 1];
    });
  });
  const top = profile(Array.from({ length: width }, (_, x) => x));
  const bottom = profile(Array.from({ length: width }, (_, x) => (height - 1) * width + x));
  const left = profile(Array.from({ length: height }, (_, y) => y * width));
  const right = profile(Array.from({ length: height }, (_, y) => y * width + width - 1));
  const model = new Float32Array(width * height * 3);
  for (let y = 0; y < height; y++) {
    const v = y / Math.max(1, height - 1);
    for (let x = 0; x < width; x++) {
      const u = x / Math.max(1, width - 1);
      for (let c = 0; c < 3; c++) {
        const corners = (1 - v) * ((1 - u) * top[0][c] + u * top[width - 1][c])
          + v * ((1 - u) * bottom[0][c] + u * bottom[width - 1][c]);
        const value = (1 - u) * left[y][c] + u * right[y][c]
          + (1 - v) * top[x][c] + v * bottom[x][c] - corners;
        model[(y * width + x) * 3 + c] = Math.min(255, Math.max(0, value));
      }
    }
  }
  return model;
}

export async function cutout(bytes, { recorte, tolerancia, recortar_borde, rellenar_bordes, suavizar_contorno, borde_suave, quitar_huecos, sombra_original }) {
  const { data, info } = await sharp(bytes).rotate().ensureAlpha().raw().toBuffer({ resolveWithObject: true });
  const { width, height } = info;
  const original = Buffer.from(data);
  const total = width * height;
  const border = [];
  for (let x = 0; x < width; x++) {
    border.push(x, (height - 1) * width + x);
  }
  for (let y = 1; y < height - 1; y++) {
    border.push(y * width, y * width + width - 1);
  }

  const alpha = new Uint8Array(total);
  const transparentBorder = border.filter(i => data[i * 4 + 3] < 250).length;
  if (transparentBorder > border.length / 2) {
    // PNG que ya viene sin fondo.
    for (let i = 0; i < total; i++) {
      alpha[i] = data[i * 4 + 3];
    }
  } else if (recorte === 'preciso') {
    const median = channel => {
      const values = border.map(i => data[i * 4 + channel]).sort((x, y) => x - y);
      return values[values.length >> 1];
    };
    const bg = [median(0), median(1), median(2)];
    // Con fondo claro, el modelo recibe una copia con más contraste: una remera crema sobre blanco
    // casi no se distingue y el modelo se quedaría solo con el estampado. Es solo para la máscara.
    let input = sharp(data, { raw: { width, height, channels: 4 } }).removeAlpha();
    if ((bg[0] + bg[1] + bg[2]) / 3 > 200) {
      input = input.linear(4, -3 * 255);
    }
    const { data: mask, info: maskInfo } = await modelMask(await input.png().toBuffer());
    if (maskInfo.width !== width || maskInfo.height !== height) {
      throw new Error('el modelo devolvió una máscara de otro tamaño');
    }
    // Silueta: lo que el modelo marca con confianza (≥ 50 %) es prenda, incluidos los huecos que deja
    // adentro (con un estampado grande a veces duda en el cuerpo de la remera). En la franja dudosa
    // (contorno con poca confianza) decide el color: lo que es igual al fondo viejo se va.
    const flood = threshold => {
      const outside = new Uint8Array(total);
      const queue = new Int32Array(total);
      let tail = 0;
      for (const i of border) {
        if (mask[i] < threshold && !outside[i]) {
          outside[i] = 1;
          queue[tail++] = i;
        }
      }
      for (let head = 0; head < tail; head++) {
        const i = queue[head];
        const x = i % width;
        for (const next of [x > 0 ? i - 1 : -1, x < width - 1 ? i + 1 : -1, i - width, i + width]) {
          if (next >= 0 && next < total && !outside[next] && mask[next] < threshold) {
            outside[next] = 1;
            queue[tail++] = next;
          }
        }
      }
      return outside;
    };
    const far = flood(8);
    const solid = flood(128);
    // Interior según el color (fondo liso inundado desde los bordes, alejado 10 px del contorno):
    // es confiable lejos del borde y cubre las zonas donde el modelo duda.
    const colorFg = Buffer.alloc(total, 255);
    {
      const queue = new Int32Array(total);
      let tail = 0;
      const flat = i => Math.max(Math.abs(data[i * 4] - bg[0]), Math.abs(data[i * 4 + 1] - bg[1]), Math.abs(data[i * 4 + 2] - bg[2])) <= tolerancia;
      for (const i of border) {
        if (colorFg[i] && flat(i)) {
          colorFg[i] = 0;
          queue[tail++] = i;
        }
      }
      for (let head = 0; head < tail; head++) {
        const i = queue[head];
        const x = i % width;
        for (const next of [x > 0 ? i - 1 : -1, x < width - 1 ? i + 1 : -1, i - width, i + width]) {
          if (next >= 0 && next < total && colorFg[next] && flat(next)) {
            colorFg[next] = 0;
            queue[tail++] = next;
          }
        }
      }
    }
    const colorCore = await sharp(colorFg, { raw: { width, height, channels: 1 } }).dilate(10).extractChannel(0).raw().toBuffer();
    for (let i = 0; i < total; i++) {
      const distance = Math.max(Math.abs(data[i * 4] - bg[0]), Math.abs(data[i * 4 + 1] - bg[1]), Math.abs(data[i * 4 + 2] - bg[2]));
      const coverage = !solid[i] || (colorCore[i] && !far[i]) ? 1 : far[i] ? 0
        : Math.min(1, Math.max(0, (distance - tolerancia) / Math.max(tolerancia * 2, 16)));
      alpha[i] = Math.round(coverage * 255);
      if (coverage > 0.25 && coverage < 0.98) {
        // Borde semitransparente: se quita el tinte del fondo viejo.
        for (let c = 0; c < 3; c++) {
          const value = bg[c] + (data[i * 4 + c] - bg[c]) / coverage;
          data[i * 4 + c] = Math.min(255, Math.max(0, Math.round(value)));
        }
      }
    }
  } else {
    const background = backgroundModel(data, width, height);
    const distances = colorDistances(data, background, total);
    const distance = i => distances[i];
    // Cada lado de la foto tiene que ser mayormente fondo liso; si no, es una foto o un collage.
    const near = i => distance(i) <= Math.max(tolerancia * 2, 20);
    const sides = [
      Array.from({ length: width }, (_, x) => x),
      Array.from({ length: width }, (_, x) => (height - 1) * width + x),
      Array.from({ length: height }, (_, y) => y * width),
      Array.from({ length: height }, (_, y) => y * width + width - 1),
    ];
    if (sides.some(side => side.filter(near).length < side.length * 0.5)) {
      throw new Error('la imagen no tiene un fondo liso (¿foto o collage?). Probá con otra foto o subí la tolerancia');
    }
    const isBackground = new Uint8Array(total);
    const queue = new Int32Array(total);
    const isFlat = i => distance(i) <= tolerancia;
    // Marca en `region` la zona conectada desde las semillas; deja sus píxeles en queue[0..tamaño].
    const fill = (seeds, accept, region) => {
      let head = 0;
      let tail = 0;
      for (const seed of seeds) {
        if (!region[seed] && accept(seed)) {
          region[seed] = 1;
          queue[tail++] = seed;
        }
      }
      while (head < tail) {
        const i = queue[head++];
        const x = i % width;
        for (const next of [x > 0 ? i - 1 : -1, x < width - 1 ? i + 1 : -1, i - width, i + width]) {
          if (next >= 0 && next < total && !region[next] && accept(next, i)) {
            region[next] = 1;
            queue[tail++] = next;
          }
        }
      }
      return tail;
    };
    fill(border, isFlat, isBackground);

    const seen = new Uint8Array(total);
    if (quitar_huecos) {
      // Zonas cerradas del color del fondo (entre brazo y cuerpo, por ejemplo).
      const minimum = total * (typeof quitar_huecos === 'number' ? quitar_huecos : 0.002);
      for (let i = 0; i < total; i++) {
        if (!isBackground[i] && !seen[i] && isFlat(i)) {
          const size = fill([i], j => !isBackground[j] && isFlat(j), seen);
          if (size >= minimum) {
            for (let j = 0; j < size; j++) {
              isBackground[queue[j]] = 1;
            }
          }
        }
      }
      seen.fill(0);
    }

    // Sombra de la foto original: el mismo fondo, solo más oscuro. Se vuelve sombra negra
    // semitransparente en lugar de quedar como un filete claro alrededor de la prenda.
    const shadowAlpha = new Uint8Array(total);
    if (sombra_original) {
      const darkening = i => {
        const k = [0, 1, 2].map(c => data[i * 4 + c] / Math.max(background[i * 3 + c], 1));
        const average = (k[0] + k[1] + k[2]) / 3;
        return Math.max(...k) - Math.min(...k) <= 0.025 && average < 1 && average >= 0.82 ? 1 - average : -1;
      };
      const reach = new Uint8Array(total);
      // La sombra varía gradualmente. Un salto de color marca el filo de la tela,
      // incluso cuando una costura crema/gris tiene el mismo matiz que el fondo.
      const maximumStep = Math.max(2, Math.min(5, tolerancia / 2));
      const size = fill(border, (j, from = j) => {
        if (isBackground[j]) {
          return true;
        }
        if (darkening(j) < 0) {
          return false;
        }
        for (let c = 0; c < 3; c++) {
          if (Math.abs(data[j * 4 + c] - data[from * 4 + c]) > maximumStep) {
            return false;
          }
        }
        return true;
      }, reach);
      const candidate = Buffer.alloc(total);
      for (let j = 0; j < size; j++) {
        const i = queue[j];
        if (!isBackground[i]) {
          candidate[i] = 255;
          isBackground[i] = 1;
        }
      }
      // Solo cuentan como sombra las franjas horizontales (bajo el ruedo y las mangas). En los costados
      // el filo iluminado de la prenda se confunde con sombra: si se oscurece parece mordido.
      const horizontal = new Uint8Array(total);
      for (let y = 0; y < height; y++) {
        let start = 0;
        for (let x = 0; x <= width; x++) {
          const inside = x < width && candidate[y * width + x];
          if (!inside) {
            if (x - start >= 24) {
              horizontal.fill(1, y * width + start, y * width + x);
            }
            start = x + 1;
          }
        }
      }
      for (let i = 0; i < total; i++) {
        if (candidate[i] && horizontal[i]) {
          shadowAlpha[i] = Math.round(darkening(i) * 255);
        } else if (candidate[i]) {
          isBackground[i] = 0;
        }
      }
    }

    // Quita restos sueltos (textos como "1 of 3", manchas): conserva solo las piezas grandes.
    const pieces = [];
    for (let i = 0; i < total; i++) {
      if (!isBackground[i] && !seen[i]) {
        const size = fill([i], j => !isBackground[j], seen);
        pieces.push({ pixels: queue.slice(0, size), size });
      }
    }
    const largest = Math.max(0, ...pieces.map(piece => piece.size));
    for (const piece of pieces) {
      if (piece.size < largest * 0.03) {
        for (const i of piece.pixels) {
          isBackground[i] = 1;
        }
      }
    }

    if (rellenar_bordes > 0) {
      // Rellena las "mordidas" del contorno: en las zonas muy iluminadas la tela es casi del color
      // del fondo y el recorte se mete adentro. Un cierre morfológico (dilatar + erosionar) tapa los
      // entrantes angostos y devuelve a esos píxeles su color original de la foto.
      const radius = Math.round(rellenar_bordes);
      // Margen alrededor para que la prenda no "se pegue" al borde de la foto al dilatar.
      const pad = radius * 2;
      const paddedWidth = width + pad * 2;
      const paddedHeight = height + pad * 2;
      const garment = Buffer.alloc(paddedWidth * paddedHeight);
      for (let i = 0; i < total; i++) {
        if (!isBackground[i]) {
          const x = i % width;
          garment[(((i - x) / width) + pad) * paddedWidth + x + pad] = 255;
        }
      }
      const raw = { raw: { width: paddedWidth, height: paddedHeight, channels: 1 } };
      const dilated = await sharp(garment, raw).erode(radius).extractChannel(0).raw().toBuffer();
      const closed = await sharp(dilated, raw).dilate(radius).extractChannel(0).raw().toBuffer();
      for (let i = 0; i < total; i++) {
        const x = i % width;
        if (closed[(((i - x) / width) + pad) * paddedWidth + x + pad] > 127 && isBackground[i]) {
          isBackground[i] = 0;
          shadowAlpha[i] = 0;
          data[i * 4] = original[i * 4];
          data[i * 4 + 1] = original[i * 4 + 1];
          data[i * 4 + 2] = original[i * 4 + 2];
        }
      }
    }

    if (suavizar_contorno > 0) {
      // Alisa el contorno: los dientes (píxeles sueltos que el recorte se comió o dejó de más)
      // se resuelven por mayoría en un entorno. Lo que vuelve a la prenda recupera su color original.
      const garment = Buffer.alloc(total);
      for (let i = 0; i < total; i++) {
        garment[i] = isBackground[i] ? 0 : 255;
      }
      const smooth = await sharp(garment, { raw: { width, height, channels: 1 } })
        .blur(Math.max(0.3, suavizar_contorno)).extractChannel(0).raw().toBuffer();
      for (let i = 0; i < total; i++) {
        if (smooth[i] >= 128 && isBackground[i]) {
          isBackground[i] = 0;
          shadowAlpha[i] = 0;
          data[i * 4] = original[i * 4];
          data[i * 4 + 1] = original[i * 4 + 1];
          data[i * 4 + 2] = original[i * 4 + 2];
        } else if (smooth[i] < 128 && !isBackground[i]) {
          isBackground[i] = 1;
        }
      }
    }

    // Capas del contorno: 1 = toca el fondo, 2 = toca la capa 1. Ahí los píxeles mezclan prenda y fondo.
    const layer = new Uint8Array(total);
    const touches = (i, test) => {
      const x = i % width;
      return (x > 0 && test(i - 1)) || (x < width - 1 && test(i + 1))
        || (i >= width && test(i - width)) || (i + width < total && test(i + width));
    };
    for (let i = 0; i < total; i++) {
      if (!isBackground[i] && touches(i, j => isBackground[j])) {
        layer[i] = 1;
      }
    }
    for (let i = 0; i < total; i++) {
      if (!isBackground[i] && !layer[i] && touches(i, j => layer[j] === 1)) {
        layer[i] = 2;
      }
    }

    for (let i = 0; i < total; i++) {
      if (isBackground[i]) {
        continue;
      }
      alpha[i] = 255;
      if (!layer[i]) {
        continue;
      }
      // Color de la prenda: el píxel interior más cercano.
      const x = i % width;
      const y = (i - x) / width;
      let inner = -1;
      for (let radius = 1; radius <= 4 && inner < 0; radius++) {
        for (let dy = -radius; dy <= radius && inner < 0; dy++) {
          for (let dx = -radius; dx <= radius; dx++) {
            const nx = x + dx;
            const ny = y + dy;
            const j = ny * width + nx;
            if (nx >= 0 && nx < width && ny >= 0 && ny < height && !isBackground[j] && !layer[j]) {
              inner = j;
              break;
            }
          }
        }
      }
      if (inner < 0) {
        continue;
      }
      // Cuánto de la prenda hay en el píxel (proyección entre fondo y prenda), y su color sin el fondo viejo.
      let dot = 0;
      let length = 0;
      for (let c = 0; c < 3; c++) {
        const towards = data[inner * 4 + c] - background[i * 3 + c];
        dot += (data[i * 4 + c] - background[i * 3 + c]) * towards;
        length += towards * towards;
      }
      if (length < 400) {
        continue;
      }
      const coverage = Math.min(1, Math.max(0.05, dot / length));
      alpha[i] = Math.round(coverage * 255);
      for (let c = 0; c < 3; c++) {
        const bg = background[i * 3 + c];
        const value = bg + (data[i * 4 + c] - bg) / coverage;
        data[i * 4 + c] = Math.min(255, Math.max(0, Math.round(value)));
      }
    }
    for (let i = 0; i < total; i++) {
      if (shadowAlpha[i]) {
        alpha[i] = shadowAlpha[i];
        data[i * 4] = data[i * 4 + 1] = data[i * 4 + 2] = 0;
      }
    }
  }

  if (transparentBorder <= border.length / 2) {
    await refineEdges(original, data, alpha, backgroundModel(original, width, height),
      width, height, tolerancia, sombra_original, suavizar_contorno);
  }

  const single = buffer => sharp(Buffer.from(buffer), { raw: { width, height, channels: 1 } });
  let base = alpha;
  if (recortar_borde > 0) {
    // Come unos píxeles del contorno: saca el filete claro de las sombras de la foto original.
    base = await single(alpha).dilate(Math.round(recortar_borde)).extractChannel(0).raw().toBuffer();
  }
  let mask = base;
  if (borde_suave > 0) {
    mask = await single(base).blur(Math.max(0.3, borde_suave)).extractChannel(0).raw().toBuffer();
  }
  let left = width;
  let top = height;
  let right = -1;
  let bottom = -1;
  for (let i = 0; i < total; i++) {
    // Solo suaviza hacia adentro: nunca recupera píxeles del fondo viejo.
    data[i * 4 + 3] = Math.min(mask[i], base[i]);
    if (data[i * 4 + 3] > 8) {
      const x = i % width;
      const y = (i - x) / width;
      left = Math.min(left, x);
      right = Math.max(right, x);
      top = Math.min(top, y);
      bottom = Math.max(bottom, y);
    }
  }
  if (right < 0) {
    throw new Error('no se encontró la prenda: probá con menos tolerancia');
  }
  return sharp(data, { raw: { width, height, channels: 4 } })
    .extract({ left, top, width: right - left + 1, height: bottom - top + 1 }).png().toBuffer();
}

async function background({ fondo, ancho, alto }) {
  if (typeof fondo === 'string' && fondo.startsWith('#')) {
    return sharp({ create: { width: ancho, height: alto, channels: 4, background: fondo } }).png().toBuffer();
  }
  if (fondo?.degradado && fondo.degradado.every(color => /^#[0-9a-f]{3,8}$/i.test(color))) {
    const [center, edge] = fondo.degradado;
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${ancho}" height="${alto}">
      <defs><radialGradient id="g" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="${center}"/><stop offset="1" stop-color="${edge}"/></radialGradient></defs>
      <rect width="100%" height="100%" fill="url(#g)"/></svg>`;
    return sharp(Buffer.from(svg)).png().toBuffer();
  }
  if (Buffer.isBuffer(fondo) || typeof fondo === 'string') {
    // Imagen de fondo: bytes o ruta de archivo.
    const bytes = Buffer.isBuffer(fondo) ? fondo : await readFile(fondo);
    return sharp(bytes).rotate().resize(ancho, alto, { fit: 'cover' }).png().toBuffer();
  }
  throw new Error('fondo inválido: usá un color (#1c1c1c), una imagen o {"degradado": ["#3a3a3a", "#141414"]}');
}

export async function compose(garmentPng, style) {
  const { ancho, alto, escala, posicion_vertical, sombra } = style;
  const garment = await sharp(garmentPng)
    .resize({ width: Math.round(ancho * escala), height: Math.round(alto * escala), fit: 'inside' }).png().toBuffer();
  const { width, height } = await sharp(garment).metadata();
  const left = Math.round((ancho - width) / 2);
  const top = Math.max(0, Math.min(alto - height, Math.round(alto * posicion_vertical - height / 2)));
  const layers = [];

  if (sombra && sombra.opacidad > 0) {
    const shapeAlpha = await sharp(garment).extractChannel(3).raw().toBuffer();
    const shadow = Buffer.alloc(ancho * alto * 4);
    for (let y = 0; y < height; y++) {
      const ty = top + y + Math.round(sombra.y);
      if (ty < 0 || ty >= alto) {
        continue;
      }
      for (let x = 0; x < width; x++) {
        const tx = left + x + Math.round(sombra.x);
        if (tx >= 0 && tx < ancho) {
          shadow[(ty * ancho + tx) * 4 + 3] = Math.round(shapeAlpha[y * width + x] * sombra.opacidad);
        }
      }
    }
    let layer = sharp(shadow, { raw: { width: ancho, height: alto, channels: 4 } });
    if (sombra.desenfoque > 0) {
      layer = layer.blur(Math.max(0.3, sombra.desenfoque / 2));
    }
    layers.push({ input: await layer.png().toBuffer(), left: 0, top: 0 });
  }
  layers.push({ input: garment, left, top });
  return sharp(await background(style)).composite(layers).webp({ quality: 90, effort: 5 }).toBuffer();
}


// Imagen de mockup (bytes) → WebP con el fondo y las opciones indicadas.
export async function generate(imageBytes, options = {}) {
  const style = merge(options);
  return compose(await cutout(imageBytes, style), style);
}
