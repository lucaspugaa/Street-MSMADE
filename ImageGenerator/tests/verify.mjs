import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { once } from 'node:events';
import { readFile, writeFile, mkdir, readdir, unlink } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';
import { cutout, merge, DEFAULTS } from '../lib/mockup.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const scratch = path.join(root, 'scratch/verification');
const destination = path.join(scratch, 'salida elegida');
const configPath = path.join(root, 'config.json');
const base = 'http://127.0.0.1:4173';
let server;
let oldConfig;
try { oldConfig = await readFile(configPath); } catch (e) { if (e.code !== 'ENOENT') throw e; }
await mkdir(scratch, { recursive: true });
for (const file of ['server.mjs', 'cli.mjs', 'lib/mockup.mjs', 'lib/output.mjs', 'lib/validation.mjs', 'public/app.js']) {
  const check = spawnSync(process.execPath, ['--check', path.join(root, file)], { windowsHide: true });
  assert.equal(check.status, 0, check.stderr.toString());
}
console.log('PASS sintaxis');
async function start() {
  server = spawn(process.execPath, ['server.mjs'], { cwd: root, env: { ...process.env, PORT: '4173' }, windowsHide: true });
  server.stderr.on('data', b => process.stderr.write(b));
  await new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('El servidor no inició')), 20000);
    server.once('error', e => { clearTimeout(timeout); reject(e); });
    server.once('exit', code => { clearTimeout(timeout); reject(new Error(`Salida anticipada: ${code}`)); });
    server.stdout.on('data', b => {
      process.stdout.write(b);
      if (b.toString().includes(base)) { clearTimeout(timeout); resolve(); }
    });
  });
}
async function stop() {
  if (!server || server.exitCode !== null) return;
  const exited = once(server, 'exit'); server.kill(); await exited;
}
const post = (url, body) => fetch(base + url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body), signal: AbortSignal.timeout(180000) });
async function files(dir) {
  const found=[];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const p=path.join(dir,entry.name);
    if(entry.isDirectory()) found.push(...await files(p));
    else if(/\.(png|jpe?g|webp)$/i.test(entry.name)) found.push(p);
  }
  return found;
}
try {
  // Gray cream fabric can look like a neutral shadow, but its edge is a sharp color step.
  const width=160, height=180;
  const pixels=Buffer.alloc(width*height*4,255);
  for(let y=40;y<140;y++) for(let x=40;x<120;x++) {
    const i=(y*width+x)*4; pixels[i]=pixels[i+1]=pixels[i+2]=222;
  }
  for(let y=75;y<100;y++) for(let x=65;x<95;x++) {
    const i=(y*width+x)*4; pixels[i]=20;pixels[i+1]=30;pixels[i+2]=40;
  }
  const cream=await sharp(pixels,{raw:{width,height,channels:4}}).png().toBuffer();
  await writeFile(path.join(scratch,'crema-sintetica.png'),cream);
  const fast=merge({recorte:'rapido',recortar_borde:0,rellenar_bordes:0,suavizar_contorno:0,borde_suave:0,sombra_original:true});
  const cropped=await cutout(cream,fast);
  const metadata=await sharp(cropped).metadata();
  assert.equal(metadata.width,80);assert.equal(metadata.height,100);
  console.log('PASS recorte crema: conserva ambos lados y el cuerpo');
  // Uneven illumination must be recognized locally rather than by a global border median.
  const gradient=Buffer.alloc(width*height*4,255);
  for(let y=0;y<height;y++) for(let x=0;x<width;x++) {
    const i=(y*width+x)*4;
    const value=210+Math.round(x/159*45);
    gradient[i]=gradient[i+1]=gradient[i+2]=value;
    if(x>=40&&x<120&&y>=40&&y<140) {gradient[i]=100;gradient[i+1]=70;gradient[i+2]=50;}
  }
  const uneven=await sharp(gradient,{raw:{width,height,channels:4}}).png().toBuffer();
  const unevenCrop=await sharp(await cutout(uneven,{...fast,sombra_original:false})).metadata();
  assert.equal(unevenCrop.width,80);assert.equal(unevenCrop.height,100);
  console.log('PASS fondo con iluminación variable desde los cuatro bordes');
  await start();
  for(const route of ['/', '/app.js', '/styles.css']) assert.equal((await fetch(base+route)).status,200);
  assert.deepEqual(await (await fetch(base+'/api/opciones')).json(),DEFAULTS);
  const initial=await (await fetch(base+'/api/config')).json();assert.ok(path.isAbsolute(initial.destino));
  for(const destino of ['', 'relativa', 'C:relativa', '\\relativa', 42]) assert.equal((await post('/api/config',{destino})).status,400);
  const notDirectory=path.join(scratch,'archivo.txt');await writeFile(notDirectory,'prueba');
  assert.equal((await post('/api/config',{destino:notDirectory})).status,400);
  assert.equal((await post('/api/config',{destino:destination})).status,200);
  assert.equal(JSON.parse(await readFile(configPath,'utf8')).destino,destination);
  console.log('PASS carpeta: validación, creación y config local');
  const imageFiles=await files(path.join(root,'IMAGES'));
  const backgroundFiles=await files(path.join(root,'IMAGES-BACKGROUND'));
  console.log(`Fotos reales disponibles: ${imageFiles.length}; fondos reales: ${backgroundFiles.length}`);
  const imageBytes=imageFiles.length?await readFile(imageFiles[0]):cream;
  const format=(await sharp(imageBytes).metadata()).format;
  const backgroundBytes=backgroundFiles.length?await readFile(backgroundFiles[0]):await sharp({create:{width:160,height:180,channels:3,background:'#183354'}}).png().toBuffer();
  const bgFormat=(await sharp(backgroundBytes).metadata()).format;
  const body={imagen:`data:image/${format};base64,${imageBytes.toString('base64')}`,fondo:`data:image/${bgFormat};base64,${backgroundBytes.toString('base64')}`,opciones:{recorte:'rapido',ancho:240,alto:300,sombra:false},destino:destination,nombre:imageFiles.length?path.basename(imageFiles[0]):'crema-sintetica.png'};
  const response=await post('/api/generar',body);assert.equal(response.status,200,response.status===200?'':await response.text());
  const bytes=Buffer.from(await response.arrayBuffer());
  const saved=decodeURIComponent(response.headers.get('X-Saved-Path'));assert.equal(path.dirname(saved),destination);assert.deepEqual(await readFile(saved),bytes);
  const result=await sharp(bytes).metadata();assert.equal(result.format,'webp');assert.equal(result.width,240);assert.equal(result.height,300);
  const repeated=await post('/api/generar',body);assert.equal(repeated.status,200);await repeated.arrayBuffer();
  assert.notEqual(decodeURIComponent(repeated.headers.get('X-Saved-Path')),saved);assert.deepEqual(await readFile(saved),bytes);
  assert.equal((await post('/api/generar',{...body,destino:'relativo'})).status,400);
  assert.equal((await post('/api/generar',{...body,opciones:{recorte:'invalido'}})).status,400);
  assert.equal((await post('/api/generar',{...body,imagen:'data:image/png;base64,AAAA'})).status,400);
  console.log(`PASS upload ${imageFiles.length?'REAL':'SINTÉTICO'}, fondo, descarga idéntica, guardado y colisiones: ${saved}`);
  if(!imageFiles.length) console.log('PENDIENTE upload real: IMAGES está vacía; no se agregó una foto falsa a esa carpeta.');
  // Exercise the recovered local model too, using the same opaque image.
  const precise=await post('/api/generar',{...body,nombre:'preciso.png',fondo:null,opciones:{recorte:'preciso',ancho:240,alto:300,sombra:false}});
  assert.equal(precise.status,200,precise.status===200?'':await precise.text());
  assert.equal((await sharp(Buffer.from(await precise.arrayBuffer())).metadata()).format,'webp');
  console.log('PASS modelo preciso local');
  await stop();await start();
  assert.equal((await (await fetch(base+'/api/config')).json()).destino,destination);
  console.log('PASS persistencia tras reiniciar');
} finally {
  await stop();
  if(oldConfig) await writeFile(configPath,oldConfig);else await unlink(configPath).catch(e=>{if(e.code!=='ENOENT')throw e});
  console.log('Servidor apagado; configuración previa restaurada.');
}
