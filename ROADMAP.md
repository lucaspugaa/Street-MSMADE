# ROADMAP – MSMADE_WEB (tema Tiendanube basado en la plantilla TEST)

> Documento de trabajo para **Claude Code** (orquestador) y **Codex** (vía MCP).
> Leer junto con `AGENTS.md` (reglas) y `CLAUDE.md` (cómo trabaja Claude Code).
> Marcar cada tarea `[x]` al terminarla y commitear el cambio de este archivo.

## 0. Objetivo

Réplica **idéntica** de la plantilla **TEST**, reorganizada en módulos (Twig + CSS + clases JS),
versionada en Git, editada por Claude Code + Codex y **hosteada por Tiendanube**.
**No hay backend externo**: Tiendanube sirve el HTML, los productos, los precios y el checkout.

```
Claude Code ──► Repo Git (src → build → theme) ──► CLI Tiendanube (watch · diff · push) ──► Preview
     ▲                                                                                     │
     │ review y módulos paralelos                                         publish MANUAL (humano)
     ▼                                                                                     ▼
   Codex (MCP)                                                                    Tienda publicada
```

Roles:

| Pieza | Rol |
| --- | --- |
| Tiendanube | Hostea el tema, sirve productos/precios, procesa el checkout |
| CLI de Tiendanube (`nuvemshop` / `tiendanube`) | El "FTP": pull, watch, diff, push, preview, publish |
| Claude Code | Dirige el trabajo, edita el código, corre build y CLI |
| Codex (MCP) | Review de cada rama y módulos en paralelo |
| Git | Historial y **único backup** (Tiendanube no respalda diseños personalizados) |
| Humano | Credenciales, decisiones de diseño y **publicar** |

## 1. Requisitos previos

| Requisito | Detalle | Verificación |
| --- | --- | --- |
| Plan de Tiendanube | Debe incluir "Diseño 100% flexible (vía HTML, CSS y JavaScript)" | Panel > Mi plan |
| Acceso al código – diseño clásico (Amazonas, Río…) | Tienda > Diseño > Editar código > **Abrir FTP** → host, usuario, contraseña | Tener las 3 credenciales |
| Acceso al código – diseño por secciones (Ipanema) | Fork con la CLI, sin FTP | `nuvemshop theme list` muestra TEST |
| Node.js | ≥ 24.15 | `node -v` |
| CLI Tiendanube | `npm install -g @tiendanube/cli` | `nuvemshop --version` |
| Git + repo privado remoto | GitHub / GitLab | `git remote -v` |
| Claude Code | Instalado y logueado | `claude --version` |
| Codex CLI + MCP | Codex logueado y servidor MCP `codex` registrado en Claude Code | `claude mcp list` muestra `codex` |

⚠️ Diseños clásicos: mientras el FTP esté abierto no se puede cambiar de tema, y **cerrar el acceso FTP borra todas las modificaciones**.

## 2. Arquitectura del repo

```text
MSMADE_WEB/
├── ROADMAP.md           # este archivo (estado del proyecto)
├── AGENTS.md            # reglas compartidas (Codex lo lee solo)
├── CLAUDE.md            # reglas de Claude Code (importa AGENTS.md)
├── .claude/settings.json# permisos: publicar está bloqueado
├── .env.example         # STORE_URL, etc. (.env NO se commitea)
├── package.json         # scripts: build, watch, lint, visual
├── scripts/
│   ├── build.mjs        # esbuild: src/ → theme/static/
│   └── visual.mjs       # Playwright + pixelmatch contra reference/
├── reference/           # capturas de TEST original (desktop 1440, mobile 390)
├── src/
│   ├── core/
│   │   ├── Universe.js      # clase base abstracta (contrato común)
│   │   └── registry.js      # data-module="X" → clase X
│   ├── modules/
│   │   ├── Benefits.js        # lógica de beneficios
│   │   ├── BenefitsLayout.js  # imágenes, orden, variantes visuales
│   │   ├── Catalogs.js
│   │   └── LandingPage.js
│   ├── styles/
│   │   ├── base.css
│   │   └── modules/ (benefits.css, catalogs.css, landing.css)
│   └── main.js
└── theme/               # lo que baja el pull de TEST (respetar su estructura)
    ├── layouts/ · templates/ · sections/ · snippets/ · config/ · locales/
    └── static/          # destino del build: js/app.js, css/app.css, img/
```

Reglas de arquitectura:

- El HTML que importa para SEO (productos, precios, textos) se queda en **Twig** con las variables nativas de Tiendanube.
- Las clases JS agregan **comportamiento** (sliders, filtros, animaciones, reglas de beneficios).
- Cada sección Twig se marca con `data-module="<Clase>"` y opcionalmente `data-config='{...}'`.
- `theme/static/js/app.js` y `theme/static/css/app.css` son **generados**: no se editan a mano.
- Los diseños clásicos traen otra estructura de carpetas: se respeta la que baje el pull.

Contrato base:

```javascript
// src/core/Universe.js
export class Universe {
  constructor(el) {
    if (new.target === Universe) throw new Error('Universe es abstracta');
    this.el = el;
    this.config = JSON.parse(el.dataset.config || '{}');
  }
  init()    { this.render(); this.bind(); }
  render()  {}   // obligatorio en cada módulo
  bind()    {}   // eventos
  destroy() {}
}

// src/modules/Benefits.js
import { Universe } from '../core/Universe.js';
export class Benefits extends Universe {
  render() { /* cuotas, envío gratis, etc. */ }
}

// src/main.js
import { registry } from './core/registry.js';
document.querySelectorAll('[data-module]').forEach(el => {
  const Mod = registry[el.dataset.module];
  if (Mod) new Mod(el).init();
});
```

```twig
{# theme/sections/benefits.tpl #}
<section class="benefits" data-module="Benefits" data-config='{{ settings.benefits_json }}'>
  {% include 'snippets/benefit-card.tpl' %}
</section>
```

## 3. Fases

Leyenda: **[HUMANO]** lo hace la persona · **[CLAUDE]** Claude Code · **[CODEX]** Codex vía MCP.

### Fase 0 · Acceso y respaldo (días 1–2)

- [x] [HUMANO] Confirmar que el plan incluye diseño 100% flexible.
- [x] [HUMANO] Indicar si TEST es **clásico** (FTP) o **por secciones** (fork). Anotarlo en `AGENTS.md` > "Datos del proyecto".
- [x] [HUMANO] Duplicar el tema como respaldo antes de tocar nada (`nuvemshop theme clone` o copia desde el panel).
- [x] ~~[HUMANO] Clásico: abrir el FTP~~ (no aplica: TEST es por secciones; se hizo `authorize`) en el panel y pasar las credenciales **por terminal**, nunca al repo.
- [x] [CLAUDE] `git init`, `.gitignore`, primer commit con `ROADMAP.md`, `AGENTS.md`, `CLAUDE.md`.
- [x] [CLAUDE] Bajar TEST a `theme/`: (pull de "TEST (Copia)" id 14597412, todavía sin fork)
  - Clásico: `nuvemshop theme ftp setup --ftp-server <host> --ftp-username <user> --ftp-password <pass> --store-url <url>` (lo corre el humano) y luego `nuvemshop theme ftp pull`.
  - Por secciones: `nuvemshop theme authorize` → `nuvemshop theme list` → `nuvemshop theme fork` → `nuvemshop theme pull --theme-id <ID_TEST>`.
- [x] [CLAUDE] Commit "TEST original" + tag `v0-original`.
- [ ] [CLAUDE] Capturar `reference/` con Playwright: home, categoría, producto, carrito × 1440 px y 390 px.
- **Cierre:** el repo tiene TEST completo, el tag `v0-original` y las capturas de referencia.

### Fase 1 · Andamiaje (días 2–3)

- [x] [CLAUDE] `package.json` con `esbuild`, `playwright`, `pixelmatch`, `pngjs` y scripts `build`, `watch`, `lint`, `visual`.
- [x] [CLAUDE] `scripts/build.mjs` (src → theme/static) y `scripts/visual.mjs` (compara preview vs `reference/`, umbral configurable).
- [ ] [CLAUDE] `src/core/Universe.js`, `registry.js`, `main.js` vacíos; incluir `app.js` y `app.css` en el layout de TEST con el mismo filtro que ya usa TEST para sus assets.
  - Andamiaje JS/CSS creado y build/lint verificados. Falta incluir app.js/app.css en el layout (cuando esté bajado TEST) y la comparación visual (cuando haya referencias).
- [x] [CLAUDE] Verificar MCP: pedirle a Codex (`codex_start`) un review de prueba del commit de andamiaje.
- **Cierre:** `npm run build` OK, la preview (`nuvemshop theme watch` o `ftp watch`) se ve idéntica a TEST y `npm run visual` = 0 diferencias.

### Fase 2 · Modularizar TEST (semanas 1–2)

Una rama por módulo (`feat/<modulo>`). Claude lidera; Codex toma el módulo paralelo en otra rama/worktree.

- [ ] [CLAUDE] `LandingPage`: orden de secciones de la home + su clase.
- [ ] [CODEX] `Benefits` + `BenefitsLayout`: sección Twig, snippet de card, CSS del módulo, imágenes en `theme/static/img/benefits/`.
- [ ] [CLAUDE] `Catalogs`: listado y filtros con variables nativas de Twig + clase de comportamiento.
- [ ] [CLAUDE/CODEX] Pasar CSS y JS inline de TEST a `src/`, módulo por módulo.
- **Cierre por módulo:** `npm run visual` sin diferencias en esa página + review de Codex aprobado + merge a `main`.

### Fase 3 · Contenido editable (semana 3)

- [ ] [CLAUDE] Textos e imágenes de beneficios y banners → configuración del tema (editables desde el panel).
- [ ] [CODEX] Auditar que productos, precios y categorías salen de la tienda (nada hardcodeado).
- **Cierre:** un texto cambiado desde el panel se ve en la preview.

### Fase 4 · QA (semanas 3–4)

- [ ] [CLAUDE] `nuvemshop theme performance --detailed` (por secciones) y corregir.
- [ ] [CLAUDE] Sin errores en consola; mobile, Chrome, Safari, Firefox.
- [ ] [HUMANO] Compra de punta a punta en la preview.
- **Cierre:** consola limpia y compra de prueba completa.

### Fase 5 · Publicación (semana 4)

- [ ] [CLAUDE] `nuvemshop theme diff --detailed` → `push` (con OK del humano) → `nuvemshop theme preview`.
- [ ] [HUMANO] `nuvemshop theme publish` (**solo el humano**). Tag `v1.0`.
- **Cierre:** la tienda real muestra el tema nuevo y el respaldo de TEST sigue disponible.

### Después de publicar

Cada cambio: rama → agente → `npm run build` → preview con watch → review de Codex → push → publish manual.

## 4. Riesgos y reglas

| Riesgo | Regla |
| --- | --- |
| Cerrar el FTP borra las modificaciones (clásicos) | El FTP queda abierto mientras se use el tema; la verdad está en Git |
| Un agente publica o hace push `--force` | `deny`/`ask` en `.claude/settings.json` + regla en `AGENTS.md` |
| Claude y Codex editan el mismo archivo | Una rama/worktree por agente y por módulo |
| "Parecido" no es idéntico a TEST | `npm run visual` contra `reference/` es criterio de cierre |
| Tiendanube actualiza la base del fork | Revisar el aviso en una rama antes de aceptar |
| El MCP de Codex deja de andar | Codex sigue sirviendo por su CLI; el MCP es comodidad, no dependencia |
| Credenciales filtradas | Nunca en el repo; `.env` y config de la CLI en `.gitignore` |

## 5. Fuentes

- Cómo modificar el diseño desde el código – https://ayuda.tiendanube.com/123227-editar-el-codigo-de-diseno/como-modificar-el-diseno-desde-el-codigo-de-mi-tienda
- CLI de Tiendanube – https://ayuda.tiendanube.com/134111-asociate-con-tiendanube/como-instalar-y-utilizar-el-cli-de-tiendanube-para-editar-disenos
- Theme Development – https://dev.tiendanube.com/en/docs/developer-tools/cli/theme-development
