// Verifica que los bloques Twig nuevos (theme/blocks) rendericen el mismo HTML que el bloque de código original
// al que reemplazan (tag v0-original), sin sus <style>/<script>/<link>. Complementa a `visual --simulate`,
// que usa el HTML original y por eso no ejercita los .tpl. Se renderiza con Twig.js (no es el motor de
// Tiendanube): valida sintaxis y contenido, no los filtros propios de la plataforma (se simulan).
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import Twig from 'twig';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const ORIGINAL = 'v0-original';

Twig.extendFilter('block_attributes', () => '');
Twig.cache(false);

const git = args => execFileSync('git', args, { cwd: ROOT, maxBuffer: 1e8 }).toString();
const original = path => JSON.parse(git(['show', `${ORIGINAL}:${path}`]));

function normalize(html) {
  return html
    .replace(/<style\b[\s\S]*?<\/style>|<script\b[\s\S]*?<\/script>|<link\b[^>]*>/gi, '')
    .replace(/ data-module="[^"]*"/g, '')
    .replace(/&amp;/g, '&')
    .replace(/>\s+</g, '><')
    .replace(/\s+/g, ' ')
    .trim();
}

async function render(type, block) {
  const source = (await readFile(join(ROOT, 'theme/blocks', `${type}.tpl`), 'utf8'))
    .replace(/{%\s*schema\s*%}[\s\S]*?{%\s*endschema\s*%}/, '');
  const html = Twig.twig({ data: source, rethrow: true }).render({ block });
  // Se compara el contenido del contenedor .code-block, no el contenedor.
  return html.replace(/^[\s\S]*?<div class="code-block[^>]*>/, '').replace(/<\/div>\s*$/, '');
}

const templates = git(['ls-tree', '-r', '-z', '--name-only', ORIGINAL, 'theme/templates'])
  .split('\0').filter(path => path.endsWith('.json'));
let failures = 0;
let checked = 0;

for (const path of templates) {
  const before = original(path);
  const after = JSON.parse(await readFile(join(ROOT, path), 'utf8'));

  for (const [sectionId, section] of Object.entries(before.sections ?? {})) {
    const current = after.sections?.[sectionId];
    if (!current?.block_order || !section.block_order) continue;

    for (const [index, oldId] of section.block_order.entries()) {
      const newId = current.block_order[index];
      const oldBlock = section.blocks[oldId];
      if (oldId === newId || oldBlock?.type !== 'code') continue;

      const newBlock = current.blocks[newId];
      const label = `${path.replace('theme/templates/', '')} · ${oldId} → ${newId} (${newBlock.type})`;
      checked++;

      try {
        const rendered = normalize(await render(newBlock.type, { id: newId, settings: newBlock.settings ?? {} }));
        const expected = normalize(oldBlock.settings.code);

        if (rendered === expected) {
          console.log(`OK     ${label}`);
        } else {
          failures++;
          let i = 0;
          while (rendered[i] === expected[i]) i++;
          console.log(`DIFIERE ${label}\n  original: …${expected.slice(Math.max(0, i - 40), i + 80)}\n  nuevo:    …${rendered.slice(Math.max(0, i - 40), i + 80)}`);
        }
      } catch (error) {
        failures++;
        console.log(`ERROR  ${label}: ${error.message}`);
      }
    }
  }
}

console.log(`\n${checked - failures}/${checked} bloques equivalentes.`);
if (failures) process.exitCode = 1;
