import sharp from 'sharp';
// Ojo: en sharp, erode() agranda las zonas blancas de una máscara y dilate() las achica
// (la morfología de libvips toma el negro como figura). Acá: erode = agrandar, dilate = achicar.
import { createHash } from 'node:crypto';
import { readFile, writeFile, mkdir, access } from 'node:fs/promises';
import { resolve, isAbsolute } from 'node:path';
import { CSV_PATH, ROOT, isMain, readCSV, serializeCSV, writeAtomic } from './csv.mjs';

export const STYLES_PATH = resolve(ROOT, 'mocks/estilos.json');
const MOCKS_DIR = resolve(ROOT, 'mocks');
const CACHE_DIR = resolve(MOCKS_DIR, 'originales');
const OUTPUT_DIR = resolve(MOCKS_DIR, 'imagenes/generados');
const GENERATED_PREFIX = 'imagenes/generados/';

export const DEFAULTS = {
  fondo: '#1c1c1c',
  ancho: 1200,
  alto: 1500,
  escala: 0.78,
  posicion_vertical: 0.5,
  tolerancia: 8,
  recortar_borde: 1,
  rellenar_bordes: 8,
  suavizar_contorno: 3,
  borde_suave: 0.6,
  quitar_huecos: false,
  sombra_original: true,
  sombra: { opacidad: 0.45, desenfoque: 22, x: 0, y: 16 },
};

function merge(...layers) {
  const result = { ...DEFAULTS, sombra: { ...DEFAULTS.sombra } };
  for (const layer of layers.filter(Boolean)) {
    for (const [key, value] of Object.entries(layer)) {
      result[key] = key === 'sombra' && value ? { ...result.sombra, ...value } : value;
    }
  }
  return result;
}

const pathFromMocks = path => isAbsolute(path) ? path : resolve(MOCKS_DIR, path);

// Portada en el tamaño más grande que ofrece el CDN de Tiendanube.
export const largeUrl = url => url.replace(/-\d+-\d+\.(webp|jpe?g|png)$/i, '-1024-1024.$1');

async function exists(path) {
  return access(path).then(() => true, () => false);
}

async function sourceImage(origin, handle, pause) {
  if (!/^https?:\/\//i.test(origin)) {
    return readFile(pathFromMocks(origin));
  }
  const url = largeUrl(origin);
  const hash = createHash('sha1').update(url).digest('hex').slice(0, 8);
  const cached = resolve(CACHE_DIR, `${handle}-${hash}`);
  if (await exists(cached)) {
    return readFile(cached);
  }
  await pause();
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`no se pudo descargar la portada (${response.status})`);
  }
  const bytes = Buffer.from(await response.arrayBuffer());
  await mkdir(CACHE_DIR, { recursive: true });
  await writeFile(cached, bytes);
  return bytes;
}

// Recorta la prenda: el fondo es el color liso que toca los bordes de la foto.
export async function cutout(bytes, { tolerancia, recortar_borde, rellenar_bordes, suavizar_contorno, borde_suave, quitar_huecos, sombra_original }) {
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
  } else {
    const median = channel => {
      const values = border.map(i => data[i * 4 + channel]).sort((a, b) => a - b);
      return values[values.length >> 1];
    };
    const bg = [median(0), median(1), median(2)];
    const distance = i => Math.max(
      Math.abs(data[i * 4] - bg[0]), Math.abs(data[i * 4 + 1] - bg[1]), Math.abs(data[i * 4 + 2] - bg[2]));
    // Cada lado de la foto tiene que ser mayormente fondo liso; si no, es una foto o un collage.
    const near = i => distance(i) <= Math.max(tolerancia * 2, 20);
    const sides = [
      Array.from({ length: width }, (_, x) => x),
      Array.from({ length: width }, (_, x) => (height - 1) * width + x),
      Array.from({ length: height }, (_, y) => y * width),
      Array.from({ length: height }, (_, y) => y * width + width - 1),
    ];
    if (sides.some(side => side.filter(near).length < side.length * 0.5)) {
      throw new Error('la portada no tiene un fondo liso (¿foto o collage?). Indicá otra imagen con "origen" en mocks/estilos.json');
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
          if (next >= 0 && next < total && !region[next] && accept(next)) {
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
        const k = [0, 1, 2].map(c => data[i * 4 + c] / Math.max(bg[c], 1));
        const average = (k[0] + k[1] + k[2]) / 3;
        return Math.max(...k) - Math.min(...k) <= 0.025 && average < 1 && average >= 0.82 ? 1 - average : -1;
      };
      const reach = new Uint8Array(total);
      const size = fill(border, j => isBackground[j] || darkening(j) >= 0, reach);
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
    const largest = pieces.reduce((max, piece) => Math.max(max, piece.size), 0);
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
        const towards = data[inner * 4 + c] - bg[c];
        dot += (data[i * 4 + c] - bg[c]) * towards;
        length += towards * towards;
      }
      if (length < 400) {
        continue;
      }
      const coverage = Math.min(1, Math.max(0.05, dot / length));
      alpha[i] = Math.round(coverage * 255);
      for (let c = 0; c < 3; c++) {
        const value = bg[c] + (data[i * 4 + c] - bg[c]) / coverage;
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
  if (fondo?.degradado) {
    const [center, edge] = fondo.degradado;
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${ancho}" height="${alto}">
      <defs><radialGradient id="g" cx="50%" cy="45%" r="75%"><stop offset="0" stop-color="${center}"/><stop offset="1" stop-color="${edge}"/></radialGradient></defs>
      <rect width="100%" height="100%" fill="url(#g)"/></svg>`;
    return sharp(Buffer.from(svg)).png().toBuffer();
  }
  if (typeof fondo === 'string') {
    return sharp(await readFile(pathFromMocks(fondo))).rotate().resize(ancho, alto, { fit: 'cover' }).png().toBuffer();
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

function parseArgs(argv) {
  const options = { sets: [], solo: null };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--solo') {
      options.solo = new Set(argv[++i]?.split(',').map(value => value.trim()).filter(Boolean));
    } else if (argv[i].startsWith('--solo=')) {
      options.solo = new Set(argv[i].slice(7).split(',').map(value => value.trim()).filter(Boolean));
    } else {
      options.sets.push(argv[i]);
    }
  }
  return options;
}

export async function generateMocks({
  csvPath = CSV_PATH,
  stylesPath = STYLES_PATH,
  sets: requested = [],
  solo = null,
  delayMs = 400,
  log = console.log,
} = {}) {
  const config = JSON.parse(await readFile(stylesPath, 'utf8'));
  const styles = config.estilos || {};
  const adjustments = config.ajustes || {};
  const sets = requested.length ? requested : Object.keys(styles);
  for (const set of sets) {
    if (!styles[set]) {
      throw new Error(`No existe el estilo "${set}" en mocks/estilos.json.`);
    }
    if (!/^[a-z0-9][a-z0-9_-]*$/.test(set)) {
      throw new Error(`Nombre de estilo inválido: ${set}. Usá minúsculas, números y guiones bajos.`);
    }
  }

  const sheet = await readCSV(csvPath);
  let last = 0;
  const pause = async () => {
    const wait = last + delayMs - Date.now();
    if (wait > 0) {
      await new Promise(done => setTimeout(done, wait));
    }
    last = Date.now();
  };
  let done = 0;
  let manual = 0;
  let errors = 0;
  await mkdir(OUTPUT_DIR, { recursive: true });

  for (const set of sets) {
    const column = `fondo_${set}`;
    if (!sheet.headers.includes(column)) {
      sheet.headers.splice(sheet.headers.indexOf('estado') >= 0 ? sheet.headers.indexOf('estado') : sheet.headers.length, 0, column);
    }
    for (const row of sheet.rows) {
      if (solo && !solo.has(row.handle)) {
        continue;
      }
      const current = row[column]?.trim();
      if (current && !current.startsWith(GENERATED_PREFIX)) {
        manual++;
        continue;
      }
      const style = merge(styles[set], adjustments[row.handle], adjustments[row.handle]?.[set]);
      const origin = style.origen || row.portada_actual?.trim();
      if (!origin) {
        log(`Sin portada: ${row.handle}. Se saltea.`);
        continue;
      }
      try {
        const garment = await cutout(await sourceImage(origin, row.handle, pause), style);
        const filename = `${row.handle}-${set}.webp`;
        await writeAtomic(resolve(OUTPUT_DIR, filename), await compose(garment, style));
        row[column] = GENERATED_PREFIX + filename;
        done++;
        log(`OK ${row.handle} / ${set}`);
      } catch (error) {
        errors++;
        log(`Error: ${row.handle} / ${set}: ${error.message}`);
      }
    }
  }

  try {
    await writeAtomic(csvPath, serializeCSV(sheet));
  } catch (error) {
    if (['EBUSY', 'EPERM', 'EACCES'].includes(error.code)) {
      throw new Error('No se pudo guardar la planilla: cerrala en Excel y repetí el comando.');
    }
    throw error;
  }
  log(`Resumen: ${done} generados, ${manual} con imagen propia (no se tocaron), ${errors} con error.`);
  log('Revisá las imágenes en mocks/imagenes/generados/. Después: npm run mocks:aplicar.');
  return { done, manual, errors };
}

if (isMain(import.meta.url)) {
  try {
    await generateMocks(parseArgs(process.argv.slice(2)));
  } catch (error) {
    console.error(`No se completó la generación: ${error.message}`);
    process.exitCode = 1;
  }
}
