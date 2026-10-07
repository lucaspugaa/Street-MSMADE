# AGENTS.md – MSMADE_WEB

Reglas compartidas para todos los agentes (Claude Code, Codex). El plan y el estado están en `ROADMAP.md`.

## Datos del proyecto (completar en Fase 0)

- Plantilla de referencia: **TEST**. Se trabaja sobre la copia **"TEST (copia)"**; el original queda de respaldo.
- Tipo de diseño: **por secciones** (base Ipanema, variante Clothing-2). Verificado con `nuvemshop theme list` el 2026-10-07. No hay FTP.
- ID del tema de trabajo: **14597412** ("TEST (Copia)"). TEST original = 14559883, **es el publicado**: nunca se toca.
- Límite de temas de la tienda: 6 de 6 en uso (no se pueden crear más sin borrar uno; eso lo decide el humano).
- La CLI opera sobre el **directorio actual**: correrla siempre desde `theme/` y siempre con `--theme-id 14597412`.
- Preview del tema de trabajo: `<STORE_URL>/?theme_installation_id=14597412`.
- URL de la tienda / preview: en `.env` (`STORE_URL`), no acá

## Objetivo

Réplica pixel a pixel de TEST (ver `reference/`). **No inventar diseño**: ante una duda visual, preguntar al humano.

## Reglas de código

- Lógica modular en `src/`: cada módulo es una clase que extiende `Universe` (`src/core/Universe.js`) y se registra en `src/core/registry.js`.
- Módulos: `LandingPage`, `Benefits`, `BenefitsLayout`, `Catalogs`. Uno nuevo = clase + CSS en `src/styles/modules/` + sección/snippet Twig.
- HTML de productos, precios, categorías y textos SEO **siempre en Twig** con variables nativas de Tiendanube. JS solo para comportamiento.
- `theme/static/js/app.js` y `theme/static/css/app.css` son generados por `npm run build`: **no editarlos a mano**.
- Respetar la estructura de carpetas que bajó la CLI dentro de `theme/`.
- Sin dependencias de runtime en el navegador salvo que el humano lo apruebe.

## Comandos

- `npm run build` – compila `src/` a `theme/static/`
- `npm run watch` – build en modo watch
- `npm run lint`
- `npm run visual` – compara capturas de la preview contra `reference/`
- Preview: `nuvemshop theme watch --theme-id 14597412 --no-browser` (desde `theme/`)
- Diff: `nuvemshop theme diff --theme-id 14597412 --detailed` (desde `theme/`)

## Prohibido sin pedido explícito del humano

- `nuvemshop theme publish` (lo corre **solo** el humano)
- `push --force`, `theme delete`, `theme update`
- Cerrar el FTP, cambiar de tema activo
- Escribir credenciales en cualquier archivo del repo

## Flujo de cada cambio

1. Rama propia: `feat/<modulo>` o `fix/<tema>`. Si dos agentes trabajan a la vez, worktrees separados.
2. `npm run build` y `npm run lint` sin errores.
3. `npm run visual` sin diferencias en las páginas afectadas.
4. Review del otro agente (Codex revisa lo de Claude y viceversa) contra estas reglas.
5. Commit chico, mensaje en español: `feat(benefits): ...`.
6. Marcar la tarea en `ROADMAP.md`.

## Criterio de "terminado"

Idéntico a TEST en 1440 px y 390 px, consola limpia, review aprobado, tarea marcada en `ROADMAP.md`.
