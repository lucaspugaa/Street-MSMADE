// Completa la planilla con las imágenes de una carpeta: cada archivo se asigna al producto cuyo
// handle coincide con su nombre (<handle>.webp, <handle>-mock.webp o <handle>-01-mock.webp).
// Solo cambia la ruta en la celda; el nombre del archivo se conserva.
import { readdir } from 'node:fs/promises';
import { extname, resolve } from 'node:path';
import { CSV_PATH, isMain, readCSV, serializeCSV, writeAtomic } from './csv.mjs';

const IMAGE = /^\.(png|jpe?g|webp)$/i;

export function parseArgs(args) {
  const options = { carpetas: [], columna: 'fondo_oscuro', conservar: false };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--columna') {
      options.columna = args[++i];
    } else if (args[i] === '--conservar') {
      options.conservar = true;
    } else if (args[i].startsWith('--')) {
      throw new Error(`opción desconocida: ${args[i]}`);
    } else {
      options.carpetas.push(args[i]);
    }
  }
  if (!options.carpetas.length) {
    throw new Error('indicá la carpeta con las imágenes, por ejemplo: npm run mocks:vincular -- "D:\\...\\COMPLETE\\KUMO"');
  }
  if (!/^fondo_[a-z0-9_]+$/.test(options.columna || '')) {
    throw new Error('la columna tiene que llamarse fondo_<nombre>, por ejemplo fondo_oscuro o fondo_azul');
  }
  return options;
}

// Nombre de archivo → handle de la planilla, o null si no corresponde a ningún producto.
export function handleFor(fileName, handles) {
  const base = fileName.slice(0, -extname(fileName).length).replace(/-mock$/i, '');
  if (handles.has(base)) {
    return base;
  }
  const withoutIndex = base.replace(/-\d{2}$/, '');
  return handles.has(withoutIndex) ? withoutIndex : null;
}

export async function linkImages({ carpetas, columna = 'fondo_oscuro', conservar = false, csvPath = CSV_PATH, log = console.log }) {
  const table = await readCSV(csvPath);
  const handles = new Set(table.rows.map(row => row.handle));
  const found = new Map();
  const unknown = [];
  for (const folder of carpetas) {
    const directory = resolve(folder);
    const files = (await readdir(directory, { withFileTypes: true }))
      .filter(entry => entry.isFile() && IMAGE.test(extname(entry.name)))
      .map(entry => entry.name)
      .sort();
    if (!files.length) {
      log(`Aviso: ${directory} no tiene imágenes PNG, JPG o WebP.`);
    }
    for (const file of files) {
      const handle = handleFor(file, handles);
      if (!handle) {
        unknown.push(file);
      } else if (found.has(handle)) {
        log(`Aviso: ${handle} tiene más de una imagen; se usa ${found.get(handle).split(/[\\/]/).pop()} y se ignora ${file}.`);
      } else {
        found.set(handle, resolve(directory, file));
      }
    }
  }

  if (!table.headers.includes(columna)) {
    table.headers.splice(table.headers.indexOf('estado') >= 0 ? table.headers.indexOf('estado') : table.headers.length, 0, columna);
    log(`Columna nueva: ${columna}.`);
  }
  const counts = { nuevos: 0, actualizados: 0, iguales: 0, conservados: 0 };
  for (const row of table.rows) {
    const path = found.get(row.handle);
    if (!path) {
      continue;
    }
    const current = row[columna] || '';
    if (current === path) {
      counts.iguales++;
    } else if (current && conservar) {
      counts.conservados++;
      log(`Se conserva ${row.handle}: ya tenía ${current}.`);
    } else {
      counts[current ? 'actualizados' : 'nuevos']++;
      row[columna] = path;
    }
  }

  if (counts.nuevos || counts.actualizados || !table.rows.every(row => columna in row)) {
    try {
      await writeAtomic(csvPath, serializeCSV(table));
    } catch (error) {
      if (error.code === 'EBUSY' || error.code === 'EPERM') {
        throw new Error('no se pudo guardar la planilla: cerrala en Excel y repetí el comando');
      }
      throw error;
    }
  }
  for (const file of unknown) {
    log(`Sin producto: ${file} (el nombre no coincide con ningún handle de la planilla).`);
  }
  log(`Listo (${columna}): ${counts.nuevos} nuevas, ${counts.actualizados} actualizadas, ${counts.iguales} sin cambios`
    + `${counts.conservados ? `, ${counts.conservados} conservadas` : ''}, ${unknown.length} sin producto.`);
  return { ...counts, sinProducto: unknown.length };
}

if (isMain(import.meta.url)) {
  try {
    await linkImages(parseArgs(process.argv.slice(2)));
  } catch (error) {
    console.error(`No se completó la vinculación: ${error.message}`);
    process.exitCode = 1;
  }
}
