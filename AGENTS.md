# AGENTS.md – MSMADE_WEB

Reglas compartidas para todos los agentes (Claude Code, Codex). El plan y el estado están en `ROADMAP.md`.

## Datos del proyecto (completar en Fase 0)

- Plantilla de referencia: **TEST**
- Tipo de diseño: **clásico (FTP)** (indicado por el humano el 2026-10-07)
- ID del tema (fork): no aplica (clásico)
- La CLI (`ftp setup`, `ftp pull`, `ftp watch`) opera sobre el **directorio actual**: correrla siempre desde `theme/`.
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
- Preview: `nuvemshop theme watch --no-browser` (fork) o `nuvemshop theme ftp watch --no-browser` (clásico)
- Diff: `nuvemshop theme diff --detailed`

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
