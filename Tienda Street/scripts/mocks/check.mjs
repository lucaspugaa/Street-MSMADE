import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { mkdtemp, mkdir, readFile, writeFile, readdir, rm } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import sharp from 'sharp';
import Twig from 'twig';
import { ROOT, parseCSV, serializeCSV, readCSV } from './csv.mjs';
import { syncProducts } from './productos.mjs';
import { applyMocks } from './aplicar.mjs';

// Todo el material de prueba se crea dentro de mocks y se elimina al terminar.
sharp.cache(false);
const temporary = await mkdtemp(resolve(ROOT, 'mocks/.prueba-'));
assert.equal(dirname(temporary), resolve(ROOT, 'mocks'));
const csvPath = resolve(temporary, 'productos.csv');
const outputDir = resolve(temporary, 'salida');
const snippetPath = resolve(temporary, 'generado.tpl');
let server;
try {
  const roundtrip = {
    headers: ['handle', 'producto', 'portada_actual', 'fondo_oscuro', 'fondo_crema', 'nota'],
    rows: [{ handle: 'viejo', producto: 'Ñandú; "edición"\nlarga', portada_actual: '', fondo_oscuro: 'oscuro.webp', fondo_crema: '', nota: 'no borrar' }],
  };
  const text = serializeCSV(roundtrip);
  assert.ok(Buffer.from(text).subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])));
  assert.deepEqual(parseCSV(text), roundtrip);
  assert.throws(() => parseCSV('handle;producto\na;"sin cerrar'), /comillas/);
  assert.throws(() => parseCSV('handle;producto\na;Uno\na;Dos'), /repetido/);
  await writeFile(csvPath, text);

  const requests = [];
  const card = (handle, name) => `<div class="js-product-item-private"><a class="js-product-item-image-link-private" href="/productos/${handle}/?variant=1" title="${name}"><img src="data:image/gif;base64,x" data-srcset="/portada.webp 480w, /grande.webp 1600w"></a><div class="js-item-name">${name}</div></div>`;
  let mode = 'normal';
  server = createServer((request, response) => {
    requests.push({ method: request.method, path: request.url, time: Date.now(), cookie: request.headers.cookie });
    response.setHeader('Content-Type', 'text/html; charset=utf-8');
    if (mode === 'failure' && request.url.includes('/page/')) {
      response.writeHead(503);
      response.end('No disponible');
    } else if (mode === 'repeat') {
      response.end(card('nuevo', 'Árbol'));
    } else if (request.url === '/productos/') {
      response.end(card('nuevo', 'Árbol'));
    } else if (request.url === '/productos/page/2/?results_only=true') {
      response.end('<div class="last-page"></div>' + card('otro', 'Zorro &amp; compañía'));
    } else {
      response.writeHead(404);
      response.end();
    }
  });
  await new Promise(done => server.listen(0, '127.0.0.1', done));
  const storeUrl = `http://127.0.0.1:${server.address().port}`;
  const log = [];
  await syncProducts({ storeUrl, csvPath, delayMs: 30, log: message => log.push(message) });
  assert.equal(requests.length, 2);
  assert.ok(requests.every(request => request.method === 'GET' && request.cookie === undefined));
  assert.ok(requests[1].time - requests[0].time >= 30);
  const updated = await readCSV(csvPath);
  assert.deepEqual(updated.rows.map(row => row.producto), ['Árbol', 'Ñandú; "edición"\nlarga', 'Zorro & compañía']);
  assert.equal(updated.rows[1].estado, 'no disponible');
  assert.equal(updated.rows[1].fondo_oscuro, 'oscuro.webp');
  assert.equal(updated.rows[1].nota, 'no borrar');
  assert.ok(updated.headers.includes('fondo_crema'));
  assert.equal(updated.rows[0].portada_actual, `${storeUrl}/portada.webp`);
  const preserved = await readFile(csvPath);
  mode = 'failure';
  await assert.rejects(syncProducts({ storeUrl, csvPath, delayMs: 0, log: () => {} }), /503/);
  assert.ok((await readFile(csvPath)).equals(preserved));
  mode = 'repeat';
  await assert.rejects(syncProducts({ storeUrl, csvPath, delayMs: 0, log: () => {} }), /repite productos/);
  assert.ok((await readFile(csvPath)).equals(preserved));

  await sharp({ create: { width: 2100, height: 1000, channels: 4, background: '#223344' } }).png().toFile(resolve(temporary, 'grande;oscuro.png'));
  await sharp({ create: { width: 600, height: 300, channels: 3, background: '#ded2bf' } }).jpeg().toFile(resolve(temporary, 'chico.jpg'));
  const inputs = {
    headers: ['handle', 'producto', 'portada_actual', 'fondo_oscuro', 'fondo_crema_suave', 'estado'],
    rows: [
      { handle: 'nuevo', producto: 'Árbol', fondo_oscuro: 'grande;oscuro.png', fondo_crema_suave: resolve(temporary, 'chico.jpg') },
      { handle: 'sin-mock', producto: 'Sin mock' },
    ],
  };
  await writeFile(csvPath, serializeCSV(inputs));
  await mkdir(outputDir);
  await writeFile(resolve(outputDir, 'huerfano.webp'), 'archivo huérfano');
  await writeFile(resolve(outputDir, 'notas.txt'), 'se conserva');
  let builds = 0;
  const options = { csvPath, outputDir, snippetPath, build: async () => { builds++; }, log: message => log.push(message) };
  const first = await applyMocks(options);
  assert.equal(first.applied, 2);
  assert.equal(first.removed, 1);
  assert.ok(log.some(message => message.includes('600 px')));
  assert.deepEqual((await readdir(outputDir)).sort(), ['notas.txt', 'nuevo-crema_suave.webp', 'nuevo-oscuro.webp']);
  assert.equal((await sharp(await readFile(resolve(outputDir, 'nuevo-oscuro.webp'))).metadata()).width, 1600);
  assert.equal((await sharp(await readFile(resolve(outputDir, 'nuevo-crema_suave.webp'))).metadata()).width, 600);
  Twig.extendFilter('static_url', value => `https://cdn.test/${value}?x="a"&y=1`);
  const snippet = await readFile(snippetPath, 'utf8');
  const rendered = Twig.twig({ data: snippet, rethrow: true }).render({});
  assert.ok(rendered.includes('&quot;'));
  assert.ok(rendered.includes('Fondo crema suave'));
  assert.ok(rendered.includes('images/mocks/nuevo-oscuro.webp'));
  assert.ok(!rendered.includes('sin-mock'));
  const second = await applyMocks(options);
  assert.equal(second.same, 2);
  assert.equal(second.applied, 0);
  assert.equal(builds, 2);
  assert.equal(await readFile(snippetPath, 'utf8'), snippet);

  const savedImage = await readFile(resolve(outputDir, 'nuevo-oscuro.webp'));
  inputs.rows[0].fondo_oscuro = 'no-existe.png';
  await writeFile(csvPath, serializeCSV(inputs));
  await assert.rejects(applyMocks(options), /conservó la versión/);
  assert.ok((await readFile(resolve(outputDir, 'nuevo-oscuro.webp'))).equals(savedImage));
  assert.equal(await readFile(snippetPath, 'utf8'), snippet);
  assert.equal(builds, 2);
  await writeFile(resolve(temporary, 'dañado.jpg'), 'no es imagen');
  inputs.rows[0].fondo_oscuro = 'dañado.jpg';
  await writeFile(csvPath, serializeCSV(inputs));
  await assert.rejects(applyMocks(options), /conservó la versión/);
  inputs.rows[0].fondo_oscuro = '';
  inputs.rows[0].fondo_crema_suave = '';
  await writeFile(csvPath, serializeCSV(inputs));
  const cleared = await applyMocks(options);
  assert.equal(cleared.removed, 2);
  assert.deepEqual(await readdir(outputDir), ['notas.txt']);
  assert.ok(Twig.twig({ data: await readFile(snippetPath, 'utf8'), rethrow: true }).render({}).includes('data-module="MocksModified"'));
  console.log('OK mocks: CSV/BOM/Excel, GET con pausa y paginación, actualización sin pérdida, errores sin escritura, imágenes/rutas/1600px, aviso 800px, Twig, huérfanos y segunda ejecución sin cambios.');
} finally {
  if (server) {
    await new Promise(done => server.close(done));
  }
  assert.equal(dirname(resolve(temporary)), resolve(ROOT, 'mocks'));
  await rm(temporary, { recursive: true, force: true, maxRetries: 5, retryDelay: 100 });
}
