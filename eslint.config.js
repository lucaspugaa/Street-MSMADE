import js from '@eslint/js';
import globals from 'globals';

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.js'],
    languageOptions: { globals: globals.browser },
  },
  {
    // Copias fieles de los scripts del editor: se avisa, pero no se bloquea, hasta refactorizarlas.
    files: ['src/modules/legacy/**/*.js'],
    rules: { 'no-unused-vars': 'warn' },
  },
  {
    files: ['scripts/**/*.mjs', 'scripts/**/*.js', 'eslint.config.js'],
    languageOptions: { globals: globals.node },
  },
];
