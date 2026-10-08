// Verifica que los bloques Twig nuevos (theme/blocks) rendericen el mismo HTML que el bloque de código original
// al que reemplazan (tag tienda-v0-original / v0-original), sin sus <style>/<script>/<link>. Complementa a `visual --simulate`,
// que usa el HTML original y por eso no ejercita los .tpl. Se renderiza con Twig.js (no es el motor de
// Tiendanube): valida sintaxis y contenido, no los filtros propios de la plataforma (se simulan).
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import Twig from 'twig';
import assert from 'node:assert/strict';
import { originalJson, originalRef, originalTemplates } from './lib/original.mjs';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const ORIGINAL = originalRef(ROOT);

Twig.extendFilter('block_attributes', () => '');
Twig.extendFilter('resolve_media', value => ({ sourceUrl: `https://example.test/${value.slice(11)}.webp` }));
Twig.cache(false);

const original = path => originalJson(ROOT, ORIGINAL, path);

// Etiquetas de bloque: el espacio en blanco junto a ellas no se renderiza. Junto a elementos inline
// (a, span, strong, img…) sí puede verse, así que ahí NO se normaliza y cualquier diferencia cuenta.
const BLOCK = 'address|article|aside|blockquote|div|footer|form|h[1-6]|header|li|main|nav|ol|p|section|ul';
const BLOCK_EDGE = new RegExp(`(<\\/?(?:${BLOCK})\\b[^>]*>)\\s+|\\s+(?=<\\/?(?:${BLOCK})\\b)`, 'gi');

function normalize(html) {
  return html
    .replace(/<style\b[\s\S]*?<\/style>|<script\b[\s\S]*?<\/script>|<link\b[^>]*>/gi, '')
    .replace(/ data-module="[^"]*"/g, '')
    .replace(/&amp;/g, '&')
    .replace(BLOCK_EDGE, (match, tag) => tag ?? '')
    .trim();
}

async function render(type, block) {
  const source = (await readFile(join(ROOT, 'theme/blocks', `${type}.tpl`), 'utf8'))
    .replace(/{%\s*schema\s*%}[\s\S]*?{%\s*endschema\s*%}/, '');
  const html = Twig.twig({ data: source, rethrow: true }).render({ block });
  // Se compara el contenido del contenedor .code-block, no el contenedor.
  return html.replace(/^[\s\S]*?<div class="code-block[^>]*>/, '').replace(/<\/div>\s*$/, '');
}

const templates = originalTemplates(ROOT, ORIGINAL);
let failures = 0;
let checked = 0;

// Render the complete new section, including the flex wrapper and both empty children.
// The expected portal comes exclusively from code_4h5e in the original tag.
const homePath = 'theme/templates/pages/home.json';
const home = JSON.parse(await readFile(join(ROOT, homePath), 'utf8'));
const street = home.sections.home_street;
const stripSchema = source => source.replace(/{%\s*schema\s*%}[\s\S]*?{%\s*endschema\s*%}/, '');
const bannerSource = stripSchema(await readFile(join(ROOT, 'theme/blocks/home-universe-banner.tpl'), 'utf8'));
Twig.twig({ id: 'blocks/home-universe-banner.tpl', data: bannerSource, rethrow: true });
const sectionSource = stripSchema(await readFile(join(ROOT, 'theme/sections/home-street.tpl'), 'utf8'));
const renderStreet = section => Twig.twig({ data: sectionSource, rethrow: true, allowInlineIncludes: true }).render({ section });
const orderedStreet = { ...street, id: 'home_street', blocks: street.block_order.filter(id => !street.blocks[id].disabled).map(id => ({ ...street.blocks[id], id })) };
const oldHome = original(homePath).sections.custom_1790906164690;
const oldPortal = oldHome.blocks.code_4h5e.settings.code;
const expectedChildren = `<div class="code-block block-fill" data-store="code-block-home_portal">${oldPortal}</div>
<div class="code-block block-fill" data-store="code-block-landing_page" data-countdown-target="2026-10-21T00:00:00-03:00" data-countdown-label="21 OCT 2026 / ARGENTINA · CUENTA HASTA EL DÍA DEL SHOW"></div>
<div class="code-block block-fill" data-store="code-block-home_layouts"></div>`;
const customTemplate = await readFile(join(ROOT, 'theme/sections/custom.tpl'), 'utf8');
// Explicit falsy values emulate Twig/PHP for omitted settings: Twig.js treats its
// undefined sentinel differently in ternaries. Keep the template's own fallbacks.
const customDefaults = { mobile_direction_enabled: false, section_width: '', alignment: '', alignment_vertical: '', custom_background_color: '', custom_text_color: '' };
const customSource = stripSchema(customTemplate)
  .replace(/{% for block in section.blocks %}[\s\S]*?{% endfor %}/, expectedChildren);
const expectedStreet = Twig.twig({ data: customSource, rethrow: true }).render({ section: { id: 'home_street', settings: { ...customDefaults, ...oldHome.settings } } });
checked++;
try {
  const rendered = normalize(renderStreet(orderedStreet));
  const expected = normalize(expectedStreet);
  if (rendered !== expected) {
    let i = 0;
    while (rendered[i] === expected[i]) i++;
    throw new Error(`original: …${expected.slice(Math.max(0, i - 40), i + 100)}\n  nuevo: …${rendered.slice(Math.max(0, i - 40), i + 100)}`);
  }
  console.log('OK     home · Home Street completa → code_4h5e + wrapper custom + dos contenedores vacíos');
} catch (error) {
  failures++;
  console.log(`ERROR  home · Home Street: ${error.message}`);
}

checked++;
try {
  const edited = structuredClone(orderedStreet);
  edited.settings.masthead_title = 'OTRA <MARCA>';
  edited.settings.nav_kumo = '/anime/?coleccion=1&color=2';
  edited.settings.countdown_target = '2027-01-01T12:30:00-03:00';
  edited.settings.countdown_label = 'Nuevo lanzamiento';
  edited.blocks.reverse();
  const kumo = edited.blocks.find(b => b.settings.variant === 'kumo');
  kumo.settings.image = '@media-lib:editor-kumo';
  const bts = edited.blocks.find(b => b.settings.variant === 'bts');
  bts.settings.image = 'https://example.test/bts.webp';
  bts.settings.image_2 = '@media-lib:editor-bts';
  bts.settings.title = 'NUEVO BTS';
  bts.settings.link = '/bts/';
  const rendered = renderStreet(edited);
  assert.ok(rendered.includes('OTRA &lt;MARCA&gt;'));
  assert.ok(rendered.includes('/anime/?coleccion=1&amp;color=2'));
  assert.ok(rendered.includes('data-countdown-target="2027-01-01T12:30:00-03:00"'));
  assert.ok(rendered.includes('data-countdown-label="Nuevo lanzamiento"'));
  assert.ok(rendered.indexOf('portal-f1') < rendered.indexOf('portal-bts'));
  assert.ok(rendered.includes('src="https://example.test/editor-kumo.webp"'));
  assert.ok(!rendered.includes(' srcset='));
  assert.ok(rendered.includes('src="https://example.test/bts.webp"'));
  assert.ok(rendered.includes('src="https://example.test/editor-bts.webp"'));
  assert.ok(rendered.includes('<h2>NUEVO BTS</h2>'));
  assert.ok(rendered.includes('href="/bts/"'));
  console.log('OK     home · edición de textos, links, fecha, orden y reemplazos de imagen (URL / @media-lib)');
} catch (error) {
  failures++;
  console.log(`ERROR  home · settings editables: ${error.message}`);
}

for (const path of templates) {
  const before = original(path);
  const after = JSON.parse(await readFile(join(ROOT, path), 'utf8'));

  for (const [sectionId, section] of Object.entries(before.sections ?? {})) {
    const current = after.sections?.[sectionId];
    if (path === homePath && sectionId === 'custom_1790906164690') continue;
    if (!current?.block_order || !section.block_order) continue;

    for (const [index, oldId] of section.block_order.entries()) {
      const newId = current.block_order[index];
      const oldBlock = section.blocks[oldId];
      if (oldId === newId || oldBlock?.type !== 'code') continue;

      const newBlock = current.blocks[newId];
      if (!newBlock) continue; // Global module mounts moved to layout.tpl.
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
