import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { once } from 'node:events';
import net from 'node:net';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFile, mkdir, writeFile, unlink } from 'node:fs/promises';
import sharp from 'sharp';
import { detectImageFormat, imageDataURL } from '../public/image-format.js';
import { decodeImage } from '../lib/validation.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const originals = path.resolve(process.argv[2] ?? 'D:/Proyectos/Street-MSMADE-tienda/Tienda-Street/mocks/originales');
const names = [
  'remera-bts-bangtang-r45lt-d5874738',
  'remera-bts-cherry-girl-arg-wnwor-6b8822e0',
  'remera-bts-cupid-1r735-0b86e119',
  'remera-bts-cupid-arg-t42vl-275b2af1',
  'remera-bts-cupid-grey-h2t4z-4ba6b701',
];
const scratch = path.join(root, 'scratch/extensionless/results');
const configPath = path.join(root, 'config.json');
let previousConfig;
let child;
const results = [];
let errors = 0;
// FileReader adapter exercises the same frontend helper with File.type empty in Node.
globalThis.FileReader = class {
  readAsDataURL(blob) {
    blob.arrayBuffer().then(bytes => {
      this.result = `data:${blob.type};base64,${Buffer.from(bytes).toString('base64')}`;
      this.onload();
    }, () => this.onerror());
  }
};
for (const filename of ['public/image-format.js', 'public/app.js', 'lib/validation.mjs', 'tests/extensionless.mjs']) {
  const check = spawnSync(process.execPath, ['--check', path.join(root, filename)], { windowsHide: true });
  assert.equal(check.status, 0, check.stderr.toString());
}
console.log('PASS sintaxis');
for (const format of ['png', 'jpeg', 'webp']) {
  const bytes = await sharp({ create: { width: 32, height: 32, channels: 3, background: '#334455' } }).toFormat(format).toBuffer();
  assert.equal(detectImageFormat(bytes), format);
  for (const type of ['', 'text/plain', 'image/gif']) {
    const file = new File([bytes], 'sin-extension', { type });
    const url = await imageDataURL(file);
    assert.ok(url.startsWith(`data:image/${format};base64,`));
    assert.deepEqual(await decodeImage(`data:${type};base64,${bytes.toString('base64')}`), bytes);
  }
}
for (const bytes of [Buffer.from('no es una imagen'), Buffer.from('GIF89a'), Buffer.from('RIFF0000WAVE'), Buffer.from([0x89,0x50,0x4e,0x47]), Buffer.from([0xff,0xd8,0xff])]) {
  await assert.rejects(decodeImage(`data:image/png;base64,${bytes.toString('base64')}`));
}
await assert.rejects(imageDataURL(new File(['texto'], 'falsa.png', { type: 'image/png' })));
const html = await readFile(path.join(root, 'public/index.html'), 'utf8');
for (const id of ['images', 'background']) {
  const input = html.match(new RegExp(`<input[^>]*id="${id}"[^>]*>`))[0];
  assert.ok(!input.includes('accept='));
}
console.log('PASS PNG/JPEG/WebP por bytes, MIME vacío/incorrecto, rechazo de texto y firmas truncadas, inputs sin filtro');
const realFiles = [];
for (const name of names) {
  const bytes = await readFile(path.join(originals, name));
  const file = new File([bytes], name, { type: '' });
  const url = await imageDataURL(file);
  assert.deepEqual(await decodeImage(url), bytes);
  assert.equal(detectImageFormat(bytes), (await sharp(bytes).metadata()).format);
  realFiles.push({ name, bytes });
}
console.log('PASS helper del front con los cinco File.type vacíos');
async function availablePort() {
  const probe = net.createServer();
  try {
    await new Promise((resolve, reject) => { probe.once('error', reject); probe.listen(4173, '127.0.0.1', resolve); });
    await new Promise(resolve => probe.close(resolve)); return 4173;
  } catch (e) {
    if (e.code !== 'EADDRINUSE') throw e;
    const alternate = net.createServer();
    await new Promise(resolve => alternate.listen(0, '127.0.0.1', resolve));
    const port = alternate.address().port;
    await new Promise(resolve => alternate.close(resolve)); return port;
  }
}
const port = await availablePort();
const base = `http://127.0.0.1:${port}`;
try { previousConfig = await readFile(configPath); } catch (e) { if (e.code !== 'ENOENT') throw e; }
try {
  child = spawn(process.execPath, ['server.mjs'], { cwd: root, env: { ...process.env, PORT: String(port) }, windowsHide: true });
  child.stderr.on('data', data => process.stderr.write(data));
  await new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('El servidor no inició')), 20000);
    child.once('error', e => { clearTimeout(timeout); reject(e); });
    child.once('exit', code => { clearTimeout(timeout); reject(new Error(`Salida anticipada: ${code}`)); });
    child.stdout.on('data', data => {
      process.stdout.write(data);
      if (data.toString().includes(base)) { clearTimeout(timeout); resolve(); }
    });
  });
  assert.equal((await fetch(base + '/image-format.js')).status, 200);
  const post = body => fetch(base + '/api/generar', {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body), signal: AbortSignal.timeout(180000),
  });
  for (const mode of ['rapido', 'preciso']) {
    const destination = path.join(scratch, mode);
    await mkdir(destination, { recursive: true });
    for (const { name, bytes } of realFiles) {
      try {
        // Send the empty MIME that originally failed at the server boundary.
        const response = await post({ imagen: `data:;base64,${bytes.toString('base64')}`, fondo: null, nombre: name, destino: destination, opciones: { recorte: mode } });
        assert.equal(response.status, 200, response.status === 200 ? '' : await response.text());
        assert.equal(response.headers.get('Content-Type'), 'image/webp');
        const output = Buffer.from(await response.arrayBuffer());
        const saved = decodeURIComponent(response.headers.get('X-Saved-Path'));
        assert.equal(path.dirname(saved), destination);
        assert.equal(path.extname(saved), '.webp');
        assert.equal(detectImageFormat(output), 'webp');
        assert.deepEqual(await readFile(saved), output);
        const metadata = await sharp(output).metadata();
        assert.equal(metadata.width, 1200); assert.equal(metadata.height, 1500);
        results.push({ mode, name, inputFormat: detectImageFormat(bytes), saved, status: 'OK' });
        console.log(`PASS ${mode}: ${saved}`);
      } catch (error) {
        errors++;
        results.push({ mode, name, status: 'ERROR', error: error.message });
        console.error(`FAIL ${mode} ${name}: ${error.message}`);
      }
    }
  }
  const sampleBody = { fondo: null, nombre: 'falsa.png', destino: path.join(scratch,'rapido'), opciones: { recorte: 'rapido' } };
  for (const bytes of [Buffer.from('texto'), Buffer.from('GIF89a'), Buffer.from([0xff,0xd8,0xff])]) {
    const response = await post({ ...sampleBody, imagen: `data:image/png;base64,${bytes.toString('base64')}` });
    assert.equal(response.status, 400); await response.arrayBuffer();
  }
  console.log('PASS servidor rechaza archivos no válidos aunque declaren MIME de imagen');
  await writeFile(path.join(scratch, 'results.json'), JSON.stringify({ port, results }, null, 2) + '\n');
  assert.equal(errors, 0, `${errors} generaciones fallaron`);
  assert.equal(results.length, 10);
} finally {
  if (child && child.exitCode === null) { const exited = once(child, 'exit'); child.kill(); await exited; }
  if (previousConfig) await writeFile(configPath, previousConfig);
  else await unlink(configPath).catch(e => { if (e.code !== 'ENOENT') throw e; });
  console.log('Servidor de prueba apagado; configuración previa restaurada.');
}
