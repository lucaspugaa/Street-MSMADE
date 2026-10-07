import { build, context } from 'esbuild';
import { fileURLToPath } from 'node:url';

const JS_OUTPUT = 'theme/static/js/app.js';
const CSS_OUTPUT_DIR = 'theme/static/css';
// app.css (global) + page-<template>.css (solo en esa plantilla; ver theme/layouts/layout.tpl).
const CSS_ENTRIES = {
  'app': 'src/styles/app.css',
  'page-home': 'src/styles/pages/home.css',
  'page-category': 'src/styles/pages/category.css',
  'page-product': 'src/styles/pages/product.css',
};
const ROOT = fileURLToPath(new URL('../', import.meta.url));

const builds = [
  {
    absWorkingDir: ROOT,
    entryPoints: ['src/main.js'],
    outfile: JS_OUTPUT,
    bundle: true,
    format: 'iife',
    target: 'es2018',
    minify: true,
    sourcemap: false,
  },
  {
    absWorkingDir: ROOT,
    entryPoints: CSS_ENTRIES,
    outdir: CSS_OUTPUT_DIR,
    bundle: true,
    minify: true,
    sourcemap: false,
  },
];

if (process.argv.includes('--watch')) {
  const contexts = await Promise.all(builds.map(options => context(options)));

  await Promise.all(contexts.map(buildContext => buildContext.watch()));
  console.log('Observando src/ para compilar JS y CSS.');

  const stop = async () => {
    await Promise.all(contexts.map(buildContext => buildContext.dispose()));
    process.exit(0);
  };

  process.once('SIGINT', stop);
  process.once('SIGTERM', stop);
} else {
  await Promise.all(builds.map(options => build(options)));
  console.log('Build completo: JS y CSS generados en theme/static/.');
}
