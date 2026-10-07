// Acceso al tema original (antes de la migración) guardado en Git.
// La tienda vive en una subcarpeta del repo (Tienda Street/), pero el tag del original apunta a un commit
// de cuando el tema estaba en la raíz: se prueba con y sin el prefijo de la carpeta.
import { execFileSync } from 'node:child_process';

const REFS = ['tienda-v0-original', 'v0-original'];

const git = (root, args) => execFileSync('git', args, { cwd: root, maxBuffer: 1e8 }).toString();

export function originalRef(root) {
  for (const ref of REFS) {
    try {
      git(root, ['rev-parse', '--verify', '--quiet', `${ref}^{commit}`]);
      return ref;
    } catch {
      // probar el siguiente
    }
  }

  throw new Error(`No encuentro el tag del tema original (${REFS.join(' / ')}). Traelo con git fetch --tags.`);
}

function prefix(root) {
  return git(root, ['rev-parse', '--show-prefix']).trim();
}

// Plantillas JSON del original, con rutas relativas a la carpeta de la tienda (theme/templates/...).
export function originalTemplates(root, ref) {
  const base = prefix(root);
  return git(root, ['ls-tree', '-r', '-z', '--name-only', '--full-tree', ref])
    .split('\0')
    .map(path => (base && path.startsWith(base) ? path.slice(base.length) : path))
    .filter(path => path.startsWith('theme/templates/') && path.endsWith('.json'));
}

export function originalJson(root, ref, path) {
  const base = prefix(root);
  const candidates = base ? [`${ref}:${base}${path}`, `${ref}:${path}`] : [`${ref}:${path}`];

  for (const spec of candidates) {
    try {
      return JSON.parse(execFileSync('git', ['show', spec], { cwd: root, maxBuffer: 1e8, stdio: ['ignore', 'pipe', 'ignore'] }).toString());
    } catch {
      // probar el siguiente
    }
  }

  throw new Error(`No encuentro ${path} en ${ref}`);
}
