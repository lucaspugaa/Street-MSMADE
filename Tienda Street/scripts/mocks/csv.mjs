import { readFile, writeFile, rename, unlink, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const ROOT = fileURLToPath(new URL('../../', import.meta.url));
export const CSV_PATH = resolve(ROOT, 'mocks/productos.csv');
export const REQUIRED = ['handle', 'producto', 'portada_actual', 'fondo_oscuro'];

export function isMain(url) {
  return Boolean(process.argv[1]) && resolve(process.argv[1]) === fileURLToPath(url);
}

export function parseCSV(text) {
  const lines = [];
  let cells = [];
  let cell = '';
  let quoted = false;
  let closed = false;
  const source = text.replace(/^\uFEFF/, '');

  for (let i = 0; i < source.length; i++) {
    const char = source[i];
    if (quoted) {
      if (char === '"' && source[i + 1] === '"') {
        cell += '"';
        i++;
      } else if (char === '"') {
        quoted = false;
        closed = true;
      } else {
        cell += char;
      }
      continue;
    }

    if (char === '"' && !cell && !closed) {
      quoted = true;
    } else if (char === ';' || char === '\n' || char === '\r') {
      cells.push(cell);
      cell = '';
      closed = false;
      if (char !== ';') {
        if (cells.some(value => value !== '')) {
          lines.push(cells);
        }
        cells = [];
        if (char === '\r' && source[i + 1] === '\n') {
          i++;
        }
      }
    } else {
      if (closed || char === '"') {
        throw new Error('CSV inválido: comillas mal cerradas. Guardá la planilla como CSV UTF-8 separado por punto y coma.');
      }
      cell += char;
    }
  }

  if (quoted) {
    throw new Error('CSV inválido: hay una celda con comillas sin cerrar.');
  }
  cells.push(cell);
  if (cells.some(value => value !== '')) {
    lines.push(cells);
  }

  const headers = lines.shift()?.map(header => header.trim()) || [];
  if (!headers.includes('handle') || new Set(headers).size !== headers.length || headers.includes('')) {
    throw new Error('La planilla necesita la columna handle y encabezados únicos, separados por ;.');
  }

  const seen = new Set();
  const rows = lines.map((values, index) => {
    if (values.length !== headers.length) {
      throw new Error(`Fila ${index + 2}: la cantidad de celdas no coincide con los encabezados.`);
    }
    const row = Object.fromEntries(headers.map((header, i) => [header, values[i]]));
    row.handle = row.handle.trim();
    if (!/^[\p{L}\p{N}][\p{L}\p{N}_-]*$/u.test(row.handle) || seen.has(row.handle)) {
      throw new Error(`Fila ${index + 2}: handle vacío, inválido o repetido (${row.handle}).`);
    }
    seen.add(row.handle);
    return row;
  });
  return { headers, rows };
}

export function serializeCSV({ headers, rows }) {
  const quote = value => {
    const text = String(value ?? '');
    return /[;"\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
  };
  return '\uFEFF' + [headers, ...rows.map(row => headers.map(header => row[header] || ''))]
    .map(values => values.map(quote).join(';')).join('\r\n') + '\r\n';
}

export async function readCSV(path = CSV_PATH) {
  return parseCSV(await readFile(path, 'utf8'));
}

export async function writeAtomic(path, contents) {
  await mkdir(dirname(path), { recursive: true });
  const temporary = `${path}.tmp-${process.pid}`;
  try {
    await writeFile(temporary, contents);
    await rename(temporary, path);
  } finally {
    await unlink(temporary).catch(error => {
      if (error.code !== 'ENOENT') {
        throw error;
      }
    });
  }
}
