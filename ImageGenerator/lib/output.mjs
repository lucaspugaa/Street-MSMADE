import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdir, readFile, rename, stat, writeFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';

const appDir = fileURLToPath(new URL('../', import.meta.url));
const configPath = path.join(appDir, 'config.json');
const defaultDestination = path.join(appDir, 'salida');

export function absoluteDestination(value) {
  if (typeof value !== 'string' || !value.trim() || value.includes('\0')) {
    throw new Error('Indicá una ruta absoluta para la carpeta destino.');
  }
  const destination = value.trim();
  const fullyQualified = process.platform === 'win32'
    ? /^(?:[a-z]:[\\/]|\\\\[^\\/]+[\\/][^\\/]+(?:[\\/]|$))/i.test(destination)
    : path.isAbsolute(destination);
  if (!fullyQualified) throw new Error('La carpeta destino tiene que ser una ruta absoluta.');
  return path.normalize(destination);
}

export async function getConfig() {
  try {
    const config = JSON.parse(await readFile(configPath, 'utf8'));
    return { destino: absoluteDestination(config.destino) };
  } catch (error) {
    if (error.code === 'ENOENT') return { destino: defaultDestination };
    throw new Error(`No se pudo leer config.json: ${error.message}`);
  }
}

export async function prepareDestination(value) {
  const destino = absoluteDestination(value);
  await mkdir(destino, { recursive: true });
  if (!(await stat(destino)).isDirectory()) throw new Error('El destino tiene que ser una carpeta.');
  return destino;
}

export async function rememberDestination(destino) {
  const temporary = `${configPath}.${randomUUID()}.tmp`;
  await writeFile(temporary, JSON.stringify({ destino }, null, 2) + '\n', { flag: 'wx' });
  await rename(temporary, configPath);
  return { destino };
}

export async function saveImage(destino, originalName, bytes) {
  const base = path.win32.basename(path.posix.basename(originalName ?? 'imagen'));
  const stem = base.replace(/\.[^.]*$/, '').replace(/[<>:"/\\|?*\x00-\x1f]/g, '_').replace(/[. ]+$/, '').slice(0, 100) || 'imagen';
  for (let index = 0; ; index++) {
    const filename = `${stem}-mock${index ? `-${index}` : ''}.webp`;
    const target = path.join(destino, filename);
    try {
      await writeFile(target, bytes, { flag: 'wx' });
      return target;
    } catch (error) {
      if (error.code !== 'EEXIST') throw error;
    }
  }
}
