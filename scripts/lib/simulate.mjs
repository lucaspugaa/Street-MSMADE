// Simulación local de la migración, sin subir nada a Tiendanube.
// Toma el HTML de la tienda publicada (TEST original) y, en el navegador de Playwright, reemplaza cada bloque de
// código que ya se migró por lo que renderiza su bloque nuevo; además inyecta los CSS/JS generados en theme/static.
// Sirve para verificar CSS y JS extraídos mientras no se pueda hacer push a la copia.
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

const MODULE_BY_TYPE = {
  'universe-hero': 'UniverseHero',
  'kumo-store': 'KumoStore',
  'product-universe': 'ProductUniverse',
};

function gitJson(root, ref, path) {
  return JSON.parse(execFileSync('git', ['show', `${ref}:${path}`], { cwd: root, maxBuffer: 1e8 }).toString());
}

function listTemplates(root, ref) {
  return execFileSync('git', ['ls-tree', '-r', '-z', '--name-only', ref, 'theme/templates'], { cwd: root })
    .toString().split('\0').filter(path => path.endsWith('.json'));
}

// Compara las plantillas del tag original con las actuales: bloque code viejo → bloque nuevo en la misma posición.
async function migratedBlocks(root, originalRef) {
  const replacements = new Map();

  for (const path of listTemplates(root, originalRef)) {
    const before = gitJson(root, originalRef, path);
    const after = JSON.parse(await readFile(join(root, path), 'utf8'));

    for (const [sectionId, section] of Object.entries(before.sections ?? {})) {
      const current = after.sections?.[sectionId];
      if (!current?.block_order || !section.block_order) continue;

      section.block_order.forEach((oldId, index) => {
        const newId = current.block_order[index];
        const oldBlock = section.blocks[oldId];
        if (oldId === newId || oldBlock?.type !== 'code') return;
        // Varias plantillas reutilizan el mismo id de bloque (code_1mdm, code_2cvl): se guarda cada variante
        // con una firma de su HTML original para elegir la correcta en cada página.
        const variants = replacements.get(oldId) ?? [];
        variants.push({ newId, signature: signature(oldBlock.settings.code), ...current.blocks[newId] });
        replacements.set(oldId, variants);
      });
    }
  }

  return replacements;
}

// Devuelve [inicio del contenido, fin del contenido, fin del </div>] del div que abre en openEnd.
function matchDiv(html, openEnd) {
  const tags = /<script\b[\s\S]*?<\/script>|<style\b[\s\S]*?<\/style>|<div\b|<\/div>/gi;
  tags.lastIndex = openEnd;
  let depth = 1;
  let match;

  while ((match = tags.exec(html))) {
    const tag = match[0].slice(0, 5).toLowerCase();
    if (tag === '<div' || tag.startsWith('<div')) depth++;
    else if (tag === '</div') {
      depth--;
      if (depth === 0) return [openEnd, match.index, tags.lastIndex];
    }
  }

  throw new Error('No se encontró el cierre del bloque');
}

function signature(html) {
  return stripAssets(html).replace(/\s+/g, '').slice(0, 300);
}

function stripAssets(html) {
  return html
    .replace(/<style\b[\s\S]*?<\/style>/gi, '')
    .replace(/<script\b[\s\S]*?<\/script>/gi, '')
    .replace(/<link\b[^>]*>/gi, '')
    .trim();
}

function transformBlocks(html, replacements, applied) {
  for (const [oldId, variants] of replacements) {
    const open = new RegExp(`<div class="code-block[^"]*"[^>]*data-block-id="${oldId}"[^>]*>`).exec(html);
    if (!open) continue;

    const [contentStart, contentEnd, closeEnd] = matchDiv(html, open.index + open[0].length);
    let inner = stripAssets(html.slice(contentStart, contentEnd));
    const block = variants.find(variant => variant.signature === signature(inner)) ?? variants[0];
    applied.push(`${oldId}→${block.newId}(${block.type}${block.settings?.universe ? ':' + block.settings.universe : ''})`);
    let wrapper = open[0]
      .replace(`id="ns-block-${oldId}"`, `id="ns-block-${block.newId}"`)
      .replace(`data-block-id="${oldId}"`, `data-block-id="${block.newId}"`)
      .replace('data-block-type="code"', `data-block-type="${block.type}"`)
      .replace(`data-store="code-block-${oldId}"`, `data-store="code-block-${block.newId}"`);

    if (block.type === 'script-module') {
      inner = '';
      if (block.settings?.module) wrapper = wrapper.replace(/>$/, ` data-module="${block.settings.module}">`);
    } else if (MODULE_BY_TYPE[block.type]) {
      inner = inner.replace(/^<(\w+)\b/, `<$1 data-module="${MODULE_BY_TYPE[block.type]}"`);
    }

    html = `${html.slice(0, open.index)}${wrapper}${inner}</div>${html.slice(closeEnd)}`;
  }

  return html;
}

export async function createSimulation(root, originalRef = 'v0-original') {
  const replacements = await migratedBlocks(root, originalRef);
  const asset = path => readFile(join(root, 'theme/static', path), 'utf8').catch(() => '');
  const appCss = await asset('css/app.css');
  const appJs = await asset('js/app.js');

  return {
    replacements,
    async transform(html) {
      const template = /<body[^>]*class="[^"]*\btemplate-([a-z-]+)/.exec(html)?.[1];
      const pageCss = ['home', 'category', 'product'].includes(template) ? await asset(`css/page-${template}.css`) : '';
      const fonts = template === 'home'
        ? '<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inter:400,700&display=swap">'
        : '';

      const applied = [];
      html = transformBlocks(html, replacements, applied);
      console.log(`  simulación (${template}): ${applied.join(' ') || 'ningún bloque migrado en esta página'}`);
      html = html.replace('</head>', `${fonts}<style data-sim="page">${pageCss}</style><style data-sim="app">${appCss}</style></head>`);

      // app.js va justo después del loader de store.js, como en theme/layouts/layout.tpl.
      const loader = html.indexOf('js/store.js');
      const loaderEnd = html.indexOf('</script>', loader) + '</script>'.length;
      const appScript = `<script data-sim="app">${appJs.replace(/<\/script/gi, '<\\/script')}</script>`;
      return loader === -1 ? html.replace('</body>', `${appScript}</body>`) : html.slice(0, loaderEnd) + appScript + html.slice(loaderEnd);
    },
  };
}
