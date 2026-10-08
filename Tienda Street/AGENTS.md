# AGENTS.md – MSMADE_WEB

Reglas compartidas para todos los agentes (Claude Code, Codex). El plan y el estado están en `ROADMAP.md`.

## Datos del proyecto (completar en Fase 0)

- Plantilla de referencia: **TEST**. Se trabaja sobre la copia **"TEST (copia)"**; el original queda de respaldo.
- Tipo de diseño: **por secciones** (base Ipanema, variante Clothing-2). Verificado con `nuvemshop theme list` el 2026-10-07. No hay FTP.
- ID del tema de trabajo: **14597412** ("TEST (Copia)"). Es el **único** tema donde se puede escribir (push/watch/fork), y solo con OK del humano.
- **TEST original = 14559883 es el tema PUBLICADO (decisión del humano). No se modifica ni se guarda nada en él**: ningún comando de la CLI lo nombra ni usa `--published`. Solo se lo *mira* como visitante (capturas de `reference/`).
- Límite de temas de la tienda: 6 de 6 en uso (no se pueden crear más sin borrar uno; eso lo decide el humano).
- La CLI opera sobre el **directorio actual**: correrla siempre desde `theme/` y siempre con `--theme-id 14597412`.
- Preview del tema de trabajo: `<STORE_URL>/?theme_installation_id=14597412`.
- URL de la tienda / preview: en `.env` (`STORE_URL`), no acá
- Repo: monorepo `Street-MSMADE` (GitHub `ezequielcorrea-ux/Street-MSMADE`). La tienda vive en `Tienda Street/` y el dashboard .NET en `Dashboard Street/`. **Todos los comandos de este archivo se corren desde `Tienda Street/`** (y la CLI desde `Tienda Street/theme/`).
- Tag del tema original: `tienda-v0-original`.

## Objetivo

Réplica pixel a pixel de TEST (ver `reference/`). **No inventar diseño**: ante una duda visual, preguntar al humano.

## Reglas de código

- Lógica modular en `src/`: cada módulo es una clase que extiende `Universe` (`src/core/Universe.js`) y se registra en `src/core/registry.js`.
- Módulos: `LandingPage`, `Benefits`, `BenefitsLayout`, `Catalogs`. Uno nuevo = clase + CSS en `src/styles/modules/` + sección/snippet Twig.
- HTML de productos, precios, categorías y textos SEO **siempre en Twig** con variables nativas de Tiendanube. JS solo para comportamiento.
- `theme/static/js/app.js`, `theme/static/css/app.css` y `theme/static/css/page-*.css` son generados por `npm run build`: **no editarlos a mano**.
- CSS: `src/styles/app.css` (global) y `src/styles/pages/<template>.css` (solo en esa plantilla, ver `layout.tpl`).
- `src/modules/legacy/` son copias fieles de los scripts del editor: se refactorizan solo con verificación visual.
- Respetar la estructura de carpetas que bajó la CLI dentro de `theme/`.
- Sin dependencias de runtime en el navegador salvo que el humano lo apruebe.

## Twig de Tiendanube: trampas conocidas

Si una plantilla tiene algo que el motor de Tiendanube no acepta, **la sección desaparece sin error** (el `<main>` queda vacío). Twig.js (`check:blocks`) es más permisivo: siempre verificar en la preview.

- `replace` va con dos argumentos: `replace(' | ', '<br>')`. La forma con hash `replace({...})` rompe el render.
- No usar `{% if block | block_attributes %}`: escribir `{{ block | block_attributes }}` directo.
- `setting_type` solo de los que ya usa Ipanema (`text`, `richtext`, `select`, `image_picker`, `url`, `color`, `range`, `toggle`…). `textarea` no existe.
- Los settings omitidos en el JSON toman el `default` del schema (p. ej. `custom` → `section_width: "page"` agrega `div.container` y `vertical_padding: 64`). Al replicar una sección, replicar también esos defaults.
- `'
'` entre comillas simples se imprime literal: para un salto de línea, poner un salto real en la plantilla.

## Comandos

- Home: `home-street.tpl` / `home-universe-banner.tpl` generan la portada editable; los dos contenedores vacíos conservan el gap original de 16 px. `LandingPage` lee la cuenta regresiva del montaje y respeta el masthead Twig.
- Imágenes: URLs originales como settings de texto; `image_picker` opcional las reemplaza (URL directa o `@media-lib:` resuelta con `resolve_media.sourceUrl`, como Ipanema). En KUMØ, al editar la URL de respaldo también se debe editar/vaciar el srcset; el selector opcional lo desactiva automáticamente.
- `StoreTheme`, `MiniCart`, `DesignMocks` se montan desde el layout tras el footer, en ese orden. Estudio 3D se conserva deshabilitado.
- `scripts/lib/simulate.mjs` es legacy para bloques de categorías/productos: **no valida Home Street ni montajes globales**. `check:blocks` renderiza la nueva home con Twig.js, compara el HTML original completo (wrapper y gap incluidos) y prueba settings editados. La fidelidad visual en Tiendanube requiere preview real.

- `npm run build` – compila `src/` a `theme/static/`
- `npm run watch` – build en modo watch
- `npm run lint`
- `npm run visual` – compara capturas de la preview (TEST (Copia)) contra `reference/`
  - `-- --live`: contra TEST publicado capturado en el momento (evita deriva de stock/precios)
  - `-- --simulate`: sin push; aplica la migración sobre TEST publicado solo en el navegador local
  - `-- --only <página>`; páginas y reglas de estabilidad en `scripts/visual.config.json`
- `npm run visual:update` – regenera `reference/` desde TEST publicado (solo lectura, como visitante)
- `npm run check:blocks` – los bloques Twig nuevos renderizan el mismo HTML que el código original (`v0-original`)
- Plantillas JSON: editarlas con `scripts/lib/theme-json.mjs` (respeta el formato original y deja diffs limpios)
- Preview: `nuvemshop theme watch --theme-id 14597412 --no-browser` (desde `theme/`)
- Diff: `nuvemshop theme diff --theme-id 14597412 --detailed` (desde `theme/`)

## Prohibido sin pedido explícito del humano

- `nuvemshop theme publish` (lo corre **solo** el humano)
- `push --force`, `theme delete`, `theme update`
- Cambiar de tema activo / publicado, o cualquier escritura sobre TEST publicado (14559883)
- Correr la CLI sin `--theme-id 14597412` explícito (el default es "el último tema bajado" y no hay que depender de eso)
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

## MocksModified · preview de portadas por producto

- Montaje en `product`, `category` y `search`; nunca en home. Clase `MocksModified`, estilos exclusivos del control/fallback en el bundle global para cubrir búsqueda también.
- Activar con `?mocks=1` (primer set disponible) o `?mocks=oscuro`. La selección se recuerda en `sessionStorage` entre páginas; `?mocks=0` borra y apaga. `Original` restaura sin recargar y conserva el control.
- Sin activación (URL ni sesión), no crea controles, observers ni solicitudes de mocks. No modifica datos de productos en Tiendanube.
- Fuente de verdad: `mocks/productos.csv` (UTF-8 con BOM, separador `;`). Imágenes de origen en `mocks/imagenes/`; rutas absolutas o relativas al CSV en columnas `fondo_*`. El handle identifica al producto, independientemente de sus fotos. `theme/snippets/mocks-modified.tpl` y `theme/static/images/mocks/` son generados por `npm run mocks:aplicar`: no editar a mano. Guía para el humano: `mocks/LEEME.md`.
- Ficha: agrega el mock como primera imagen, miniatura y link de zoom si existe. Conserva los nodos de todas las fotos originales y su orden; desplaza y restaura índices de miniaturas y contadores. Usa `prependSlide/update/removeSlide` de Swiper cuando está inicializado; antes, inserta en DOM con navegación temporal, fracción y scroll horizontal. Soporta inicialización tardía del Swiper nativo.
- Tarjetas nativas dentro de `#MainContent`: detecta el handle del link. Con slider agrega una portada; sin slider conserva el nodo original y muestra una imagen de mock en su lugar hasta volver a Original. No modifica links de compra, información ni imagen secundaria.
- MutationObserver acotado a `#MainContent`, solo activo; cubre scroll infinito, relacionados lazy y cambios de atributos lazy. Home/más vendidos quedan excluidos por montaje y guard adicional.
- Prueba aislada: `node scripts/check-mocks-modified.mjs` usa Swiper real del tema, sin `.env` ni acceso a la tienda. QA del motor Twig/preview real sigue pendiente para este ajuste local; no desplegar desde esta tarea.

## Administración de mocks con CSV

- `npm run mocks:productos`: carga STORE_URL con `process.loadEnvFile` únicamente en runtime; lee todos los productos públicos por GET, sin cookies ni login, y con 750 ms de pausa entre páginas. Parser HTML inerte con Playwright y requests del navegador bloqueados. Conserva columnas/fondos, ordena por nombre y marca ausentes como `no disponible`; no guarda un catálogo parcial ante errores.
- `npm run mocks:aplicar`: usa sharp (devDependency) para validar PNG/JPG/JPEG/WebP, avisar si el ancho es menor a 800 y producir WebP de hasta 1600 px sin agrandar. Prepara todo antes de escribir; un error de imagen conserva mocks/snippet y no corre build. Compara contenidos para informar sin cambios, elimina imágenes huérfanas solo en la carpeta generada y corre build. Las imágenes de origen no se borran.
- Columna `fondo_azul_claro` → set `azul_claro` y etiqueta `Fondo azul claro`. Celda vacía = sin mock. `estado` es informativo, no descarta fondos guardados. Generador Twig con mapas y `static_url`, JSON con `json_encode | escape`; respetar las trampas del motor de Tiendanube.
- `npm run mocks:subir`: exclusivamente para el humano; ejecuta diff y luego push desde theme/, siempre con `--theme-id 14597412`, sin `--yes`. No publica. No ejecutar este comando para verificar cambios locales.
- `node scripts/mocks/check.mjs`: fixtures de CSV/HTTP/imágenes locales, se limpian al terminar. La prueba funcional `scripts/check-mocks-modified.mjs` usa ahora la ruta de salida por handle.
- `npm run mocks:generar [estilo] [--solo h1,h2]`: genera mocks sin IA desde `portada_actual` (CDN 1024 px, caché en `mocks/originales/`, gitignored). Recorta el fondo liso por inundación desde los bordes (tolerancia, sombra original → sombra negra, piezas sueltas fuera, contorno con desmezcla de color), compone sobre fondo de color/imagen/degradado con sombra nueva y escribe `mocks/imagenes/generados/<handle>-<estilo>.webp`. Estilos y ajustes por handle en `mocks/estilos.json`. Solo escribe celdas vacías o ya generadas; nunca pisa imágenes cargadas a mano. Portadas sin fondo liso (fotos/collages) quedan con error.
