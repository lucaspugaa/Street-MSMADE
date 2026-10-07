@AGENTS.md

# Claude Code – instrucciones propias

## Al empezar cada sesión

1. Leer `ROADMAP.md` y continuar con la primera tarea `[ ]` de la fase en curso.
2. Si la tarea es **[HUMANO]**, frenar y pedírsela a la persona.
3. Al terminar una tarea: marcarla `[x]` en `ROADMAP.md` y commitear.

## Trabajo con Codex (MCP)

- El servidor MCP se llama `codex`. Herramientas: `codex_start` (nueva tarea), `codex_status` (estado), `codex_continue` (seguir una tarea), `codex_projects`.
- Verificar que esté disponible con `claude mcp list`. Si no aparece, avisar al humano: hay que registrarlo con `claude mcp add codex -- <comando>` (el mismo comando que usa la app de escritorio de Claude).
- Usar Codex para:
  - **Review** de cada rama antes del merge: pasarle el diff, `AGENTS.md` y la tarea del roadmap; pedir hallazgos concretos (archivo, línea, problema).
  - **Módulos en paralelo** marcados [CODEX] en el roadmap, en su propia rama/worktree.
- Codex no publica, no hace push a Tiendanube y no toca `main` directamente.
- Si Codex y Claude no coinciden en un review, explicar ambas posturas al humano.

## Entorno

- Windows. Node ≥ 24.15. Usar rutas relativas al repo.
- La CLI de Tiendanube puede pedir login interactivo (`authorize`, `ftp setup`): eso lo hace el humano.
