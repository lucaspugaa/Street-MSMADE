import { readFile, writeFile } from 'node:fs/promises';

// Las plantillas JSON de Tiendanube vienen en dos formatos: una sola línea al estilo json_encode de PHP
// ("/" como "\/" y lo no ASCII como \uXXXX) o indentadas con 2 espacios.
// Se detecta el formato del archivo original y se respeta, para que los diffs de Git muestren solo el cambio real.
export function detectFormat(raw) {
  return {
    indent: raw.includes('\n') ? 2 : 0,
    escapeSlashes: raw.includes('\\/'),
    escapeUnicode: /\\u[0-9a-f]{4}/i.test(raw),
    trailingNewline: raw.endsWith('\n'),
  };
}

export function stringifyThemeJson(value, format = { indent: 0, escapeSlashes: true, escapeUnicode: true }) {
  let out = JSON.stringify(value, null, format.indent || undefined);

  if (format.escapeSlashes) out = out.replace(/\//g, '\\/');
  if (format.escapeUnicode) {
    out = out.replace(/[^\x00-\x7e]/g, char => '\\u' + char.charCodeAt(0).toString(16).padStart(4, '0'));
  }

  return format.trailingNewline ? `${out}\n` : out;
}

export async function readThemeJson(path) {
  const raw = await readFile(path, 'utf8');
  return { value: JSON.parse(raw), format: detectFormat(raw) };
}

export async function writeThemeJson(path, value, format) {
  await writeFile(path, stringifyThemeJson(value, format));
}
