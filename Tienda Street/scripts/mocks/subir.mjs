import { spawn } from 'node:child_process';
import { resolve } from 'node:path';
import { ROOT, isMain } from './csv.mjs';

function command(action) {
  return new Promise((done, fail) => {
    // Comando y argumentos fijos; shell solo resuelve el ejecutable .cmd de Windows.
    const child = spawn('nuvemshop', ['theme', action, '--theme-id', '14597412'], {
      cwd: resolve(ROOT, 'theme'),
      stdio: 'inherit',
      shell: process.platform === 'win32',
    });
    child.once('error', () => fail(new Error('No se pudo iniciar nuvemshop. Pedile a quien configuró la tienda que revise la instalación.')));
    child.once('exit', code => code === 0 ? done() : fail(new Error(`Se interrumpió ${action} (código ${code}). No se continúa.`)));
  });
}

if (isMain(import.meta.url)) {
  try {
    console.log('Se revisarán los cambios y se subirán únicamente a TEST (Copia), tema 14597412.');
    await command('diff');
    console.log('Revisá los cambios y respondé la confirmación de la herramienta.');
    await command('push');
    console.log('Subida terminada a la copia. No se publicó la tienda.');
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
