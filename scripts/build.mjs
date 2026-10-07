import { build, context } from 'esbuild';
import { fileURLToPath } from 'node:url';

const JS_OUTPUT = 'theme/static/js/app.js';
const CSS_OUTPUT = 'theme/static/css/app.css';
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
    entryPoints: ['src/styles/main.css'],
    outfile: CSS_OUTPUT,
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
