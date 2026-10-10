import sharp from 'sharp';
import { readFile, readdir, mkdir, unlink } from 'node:fs/promises';
import { dirname, extname, resolve, relative, isAbsolute } from 'node:path';
import { spawn } from 'node:child_process';
import { CSV_PATH, ROOT, REQUIRED, isMain, readCSV, writeAtomic } from './csv.mjs';

export function runBuild() {
  return new Promise((done, fail) => {
    const child = spawn(process.execPath, [resolve(ROOT, 'scripts/build.mjs')], { cwd: ROOT, stdio: 'inherit' });
    child.once('error', fail);
    child.once('exit', code => code === 0 ? done() : fail(new Error(`El build terminó con código ${code}.`)));
  });
}

export function setsFrom(headers) {
  const used = new Set();
  return headers.filter(header => header.startsWith('fondo_')).map(column => {
    const suffix = column.slice(6).trim();
    const set = suffix.normalize('NFD').replace(/\p{M}/gu, '').toLowerCase().replace(/\s+/g, '_');
    if (!/^[a-z0-9][a-z0-9_-]*$/.test(set) || used.has(set)) {
      throw new Error(`Columna de fondo inválida o repetida: ${column}. Usá nombres como fondo_oscuro o fondo_azul_claro.`);
    }
    used.add(set);
    return { column, set, label: `Fondo ${suffix.replace(/[_-]+/g, ' ')}` };
  });
}

const twigString = value => `'${value.replaceAll('\\', '\\\\').replaceAll("'", "\\'")}'`;

export function generateSnippet(products, sets) {
  const entries = [...products].map(([handle, images]) =>
    `    ${twigString(handle)}: {\n${images.map(({ set, filename }) =>
      `      ${twigString(set)}: ${twigString(`images/mocks/${filename}`)} | static_url`
    ).join(',\n')}\n    }`
  );
  const labels = sets.map(({ set, label }) => `    ${twigString(set)}: ${twigString(label)}`);
  return `{# archivo generado por npm run mocks:aplicar, no editar a mano.
   Fuente: mocks/productos.csv. Clave: handle de /productos/<handle>/.
   Activar preview con ?mocks=1 o ?mocks=<set>; Original restaura las fotos.
#}
{% set mocks_modified = {
  'products': {
${entries.join(',\n')}
  },
  'labels': {
${labels.join(',\n')}
  }
} %}
<div data-module="MocksModified" data-config="{{ mocks_modified | json_encode | escape }}"></div>
`;
}

async function unchanged(path, contents) {
  try {
    return (await readFile(path)).equals(Buffer.isBuffer(contents) ? contents : Buffer.from(contents));
  } catch (error) {
    if (error.code === 'ENOENT') {
      return false;
    }
    throw error;
  }
}

export async function applyMocks({
  csvPath = CSV_PATH,
  outputDir = resolve(ROOT, 'theme/static/images/mocks'),
  snippetPath = resolve(ROOT, 'theme/snippets/mocks-modified.tpl'),
  build = runBuild,
  log = console.log,
} = {}) {
  const { headers, rows } = await readCSV(csvPath);
  for (const name of REQUIRED) {
    if (!headers.includes(name)) {
      throw new Error(`Falta la columna ${name} en la planilla.`);
    }
  }
  const sets = setsFrom(headers);
  const jobs = [];
  const products = new Map();
  let errors = 0;
  let empty = 0;
  const filenames = new Set();

  // Validar y preparar todo antes de escribir o borrar: un error conserva la versión anterior.
  for (const row of rows) {
    for (const { column, set } of sets) {
      const source = row[column]?.trim();
      if (!source) {
        empty++;
        continue;
      }
      try {
        const path = resolve(dirname(csvPath), source);
        if (!['.png', '.jpg', '.jpeg', '.webp'].includes(extname(path).toLowerCase())) {
          throw new Error('el archivo debe ser PNG, JPG, JPEG o WebP');
        }
        const bytes = await readFile(path);
        let metadata;
        try {
          metadata = await sharp(bytes).metadata();
        } catch {
          throw new Error('no se pudo leer la imagen; revisá que no esté dañada');
        }
        if (!['png', 'jpeg', 'webp'].includes(metadata.format) || !metadata.width || !metadata.height) {
          throw new Error('el contenido no es una imagen PNG, JPG o WebP válida');
        }
        const width = metadata.orientation >= 5 ? metadata.height : metadata.width;
        if (width < 800) {
          log(`Aviso: ${row.handle} / ${set} tiene ${width} px de ancho (recomendado: 800 o más). Se aplicará igual.`);
        }
        const output = await sharp(bytes).rotate().resize({ width: 1600, withoutEnlargement: true })
          .webp({ quality: 82, effort: 6 }).toBuffer();
        const filename = `${row.handle}-${set}.webp`;
        if (filenames.has(filename.toLowerCase())) {
          throw new Error('el nombre de salida coincide con otro mock; revisá handles y nombres de fondos');
        }
        filenames.add(filename.toLowerCase());
        jobs.push({ filename, output });
        if (!products.has(row.handle)) {
          products.set(row.handle, []);
        }
        products.get(row.handle).push({ set, filename });
      } catch (error) {
        errors++;
        log(`Error: ${row.handle} / ${set}: ${error.code === 'ENOENT' ? 'no se encontró el archivo indicado' : error.message}.`);
      }
    }
  }

  if (errors) {
    log(`Resumen: 0 aplicados, 0 sin cambios, ${errors} con error. No se modificó ni borró ningún mock. Corregí las celdas y repetí el comando.`);
    throw new Error('Hay imágenes con error; se conservó la versión anterior y no se ejecutó el build.');
  }

  await mkdir(outputDir, { recursive: true });
  const desired = new Set(jobs.map(job => job.filename));
  let applied = 0;
  let same = 0;
  for (const { filename, output } of jobs) {
    const path = resolve(outputDir, filename);
    if (await unchanged(path, output)) {
      same++;
    } else {
      await writeAtomic(path, output);
      applied++;
    }
  }
  const snippet = generateSnippet(products, sets);
  if (!await unchanged(snippetPath, snippet)) {
    await writeAtomic(snippetPath, snippet);
  }

  let removed = 0;
  for (const entry of await readdir(outputDir, { withFileTypes: true })) {
    if (!entry.isFile() || !['.webp', '.png', '.jpg', '.jpeg'].includes(extname(entry.name).toLowerCase()) || desired.has(entry.name)) {
      continue;
    }
    const path = resolve(outputDir, entry.name);
    const within = relative(resolve(outputDir), path);
    if (within.startsWith('..') || isAbsolute(within)) {
      throw new Error('Se rechazó una ruta fuera de la carpeta de mocks.');
    }
    await unlink(path);
    removed++;
  }

  log(`Resumen: ${applied} aplicados, ${same} sin cambios, 0 con error; ${empty} celdas sin mock, ${removed} huérfanos eliminados.`);
  log('Compilando el tema…');
  await build();
  log('Listo. Los mocks quedaron preparados localmente. Para revisarlos, el siguiente paso es npm run mocks:subir.');
  return { applied, same, removed, empty };
}

if (isMain(import.meta.url)) {
  try {
    await applyMocks();
  } catch (error) {
    console.error(`No se completó la aplicación: ${error.message}`);
    process.exitCode = 1;
  }
}
