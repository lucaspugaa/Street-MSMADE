import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFile, realpath, stat } from 'node:fs/promises';
import { DEFAULTS, generate } from './lib/mockup.mjs';
import { decodeImage, isObject, validateOptions } from './lib/validation.mjs';

const publicDir = fileURLToPath(new URL('./public/', import.meta.url));
const maxBody = 25 * 1024 * 1024;
const port = Number(process.env.PORT ?? 4173);
const mime = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8' };

function json(response, status, value) {
  response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify(value));
}

async function readJSON(request) {
  if (request.headers['content-type']?.split(';')[0].trim() !== 'application/json') {
    throw new Error('Enviá el cuerpo como application/json.');
  }
  if (Number(request.headers['content-length']) > maxBody) {
    request.resume();
    throw new Error('El pedido supera el límite de 25 MB.');
  }

  const chunks = [];
  let length = 0;
  await new Promise((resolve, reject) => {
    request.on('data', chunk => {
      length += chunk.length;
      if (length > maxBody) {
        chunks.length = 0;
        reject(new Error('El pedido supera el límite de 25 MB.'));
      } else {
        chunks.push(chunk);
      }
    });
    request.on('end', resolve);
    request.on('error', reject);
    request.on('aborted', () => reject(new Error('Se interrumpió el pedido.')));
  });

  try {
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    throw new Error('El JSON no es válido.');
  }
}

function inside(root, target) {
  const relative = path.relative(root, target);
  return relative !== '..' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative);
}

const server = http.createServer(async (request, response) => {
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('Content-Security-Policy', "default-src 'self'; img-src 'self' blob: data:; object-src 'none'; base-uri 'none'");

  let pathname;
  try {
    pathname = decodeURIComponent(new URL(request.url, 'http://127.0.0.1').pathname);
  } catch {
    json(response, 400, { error: 'La URL no es válida.' });
    return;
  }

  if (request.method === 'GET' && pathname === '/api/opciones') {
    json(response, 200, DEFAULTS);
    return;
  }

  if (request.method === 'POST' && pathname === '/api/generar') {
    let image;
    let options;
    try {
      const body = await readJSON(request);
      if (!isObject(body) || !Object.hasOwn(body, 'imagen')
          || (body.fondo !== null && typeof body.fondo !== 'string')
          || Object.keys(body).some(key => !['imagen', 'fondo', 'opciones'].includes(key))) {
        throw new Error('Enviá { imagen, fondo: dataURL o null, opciones: {} }.');
      }
      options = { ...validateOptions(body.opciones) };
      image = await decodeImage(body.imagen);
      if (body.fondo !== null) {
        options.fondo = await decodeImage(body.fondo);
      }
    } catch (error) {
      json(response, 400, { error: error.message });
      return;
    }

    try {
      const result = await generate(image, options);
      response.writeHead(200, { 'Content-Type': 'image/webp' });
      response.end(result);
    } catch (error) {
      json(response, 422, { error: error.message });
    }
    return;
  }

  if (!['GET', 'HEAD'].includes(request.method) || pathname.startsWith('/api/')) {
    json(response, 404, { error: 'No se encontró esa ruta.' });
    return;
  }

  try {
    const target = path.resolve(publicDir, `.${pathname === '/' ? '/index.html' : pathname}`);
    if (pathname.includes('\\') || pathname.includes('\0') || !inside(publicDir, target)) {
      json(response, 400, { error: 'La ruta no es válida.' });
      return;
    }
    const [root, resolved] = await Promise.all([realpath(publicDir), realpath(target)]);
    if (!inside(root, resolved) || !(await stat(resolved)).isFile()) {
      json(response, 404, { error: 'No se encontró ese archivo.' });
      return;
    }
    const content = await readFile(resolved);
    response.writeHead(200, { 'Content-Type': mime[path.extname(resolved)] ?? 'application/octet-stream' });
    response.end(request.method === 'HEAD' ? undefined : content);
  } catch {
    json(response, 404, { error: 'No se encontró ese archivo.' });
  }
});

if (!Number.isInteger(port) || port < 1 || port > 65535) {
  console.error('PORT tiene que ser un entero entre 1 y 65535.');
  process.exitCode = 1;
} else {
  server.on('error', error => {
    console.error(`No se pudo iniciar el servidor: ${error.message}`);
    process.exitCode = 1;
  });
  server.listen(port, '127.0.0.1', () => {
    console.log(`Abrí http://127.0.0.1:${port}`);
  });
}
