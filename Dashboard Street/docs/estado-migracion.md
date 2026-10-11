# Migración del dashboard del cliente a Render — estado y pendientes

Última actualización: 10/10/2026, noche. Leer completo antes de tocar código o datos.

## 1. Objetivo

Hoy el cliente (Lucas, Street 1640) usa un dashboard hecho como Artifact de Claude
(https://claude.ai/artifact/CuJBUcd7wJb3nq9mjtb2jq). Lo actualiza una **tarea programada de Claude
Desktop en la PC del cliente** a las 00:01 y 18:01 ART: lee Meta Ads y Tiendanube, calcula margen y
stock, **escribe el stock en Tiendanube** y vuelve a publicar el HTML. Por eso esa PC tiene que estar
prendida todo el día.

El objetivo es que todo eso lo haga la app .NET de este repo, desplegada en Render
(https://mismade-dashboard.onrender.com) con la base en Neon, y que la PC del cliente se pueda apagar.

La especificación completa de lo que hace la tarea del cliente está en
[reglas-artifact.md](reglas-artifact.md) (exportada por el Claude de Lucas el 10/10; sin credenciales).

## 2. Regla de oro: un solo escritor del stock de Tiendanube

El stock de la tienda lo escribe **una sola** parte a la vez. Hoy es el artifact. Render está en
**modo sombra**: calcula y guarda stock en Neon, avanza su watermark, pero no envía nada a Tiendanube.

- Lo controla `Stock__EnviarATiendanube` en Render. **Ausente o `false` = modo sombra** (default en el código).
- En Inicio, el cuadro de stock dice "Modo sombra · N sin enviar". Si dice "Stock actualizado en
  Tiendanube: N combinaciones", Render está escribiendo en la tienda.
- **Nunca** poner `Stock__EnviarATiendanube=true` sin hacer el cutover completo (sección 6).

### Incidente del 10/10 22:09 (resuelto)
Se importaron los datos a Neon **antes** de que el modo sombra estuviera desplegado. La corrida de las
22:09 envió 25 combinaciones a Tiendanube. Como Render no conocía los desacoples (sección 5.2), publicó
`beige_oversize_s` = 1 y `beige_regular_xl` = 3, que debían estar en 0. El Claude de Lucas los volvió a 0,
sincronizó los pedidos #1764-#1788 y dejó todo alineado.

**Lecciones:** (1) primero desplegar y verificar en pantalla, después tocar datos; (2) el importador
tiene que negarse a escribir si el panel no está en modo sombra (tarea 1); (3) no avanzar con nada que
escriba en la tienda sin replicar antes todas las reglas del artifact.

## 3. Qué está hecho

| Parte | Estado |
|---|---|
| Deploy Render + Neon + login | Funcionando |
| Conexión Tiendanube (OAuth) | Conectada a Street 1640 |
| Ventas de Tiendanube en la base | Funcionando; Finanzas muestra facturación bruta de hoy, mes y año |
| Sync de stock de remeras (pedidos → pool → Tiendanube) | Hecho, **con desacople** (11/10); corre en modo sombra |
| Pool manual Buzo Negro XXL Regular | Hecho, corre en modo sombra |
| Modo sombra | Desplegado (PR #9) y verificado en pantalla |
| Importador del export del artifact (`tools/Mismade.Importer`) | Hecho; Tarea 1 completa: múltiples exports, colecciones faltantes, bloqueo de modo sombra y reemplazo transaccional |
| Reglas puras de comisión, envío absorbido y costo de prenda (`Domain/Reglas.cs`) | Escritas con tests, **no conectadas** al job |
| Meta Ads (sync de insights) | Código hecho; **faltan el token y los IDs en Render** |
| Página Stock | Muestra remeras desde Neon |
| Páginas Campañas y Clientes | Solo texto fijo, sin datos |
| Margen real, historial mensual, formularios de carga | No hechos (`TODO 2, 3, 6, 8` en `SyncJob.cs`) |

### Datos en Neon (importados el 10/10 desde `export-mismade`)
50 remeras + 3.481 variantes, 24 pools de buzos/pantalones, 12 variantes de conjuntos, pool manual,
watermark #1763, último enviado de remeras, 29 ventas en negro, 4 pérdidas, 10 movimientos con Cris,
2 cambios, 2 stock de cambios, 27 gastos, 11 Pago Nube en cuotas, 9 meses de historial.

**El stock de Neon ya no coincide con el del artifact**: no tiene la carga de mercadería que Lucas hizo
el 10/10 ni la corrección de `gris_regular_m`. Es esperable: se reimporta todo en el cutover.

### Archivos de datos (fuera del repo, son datos del cliente)
- `C:\Users\Janus\Desktop\Importaciones\export-mismade` — export 1 (el importado).
- `C:\Users\Janus\Downloads\export-mismade-2.zip` — export complementario: `stock_variant_map_meta`
  (desacoples), `stock_variant_map_buzos`, `stock_variant_map_pantalones`,
  `stock_buzos_pantalones_meta`, `stock_manual_pools_meta`, y stock actualizado. **Todavía no importado.**
- El artifact pertenece a la organización de claude.ai del cliente: desde nuestro Claude Code **no se
  puede leer su base**. Cualquier dato nuevo hay que pedírselo al Claude de Lucas como export JSON.

## 4. Cómo se trabaja en este repo

- **Sin ramas nuevas: todo directo a `main`** (pedido del dueño). Antes de commitear, verificar
  `git branch --show-current`: GitHub Desktop cambia de rama solo y guarda stashes.
- El push lo hace el dueño desde GitHub Desktop (la terminal de Claude no tiene credenciales de GitHub).
- Render despliega automáticamente cada push a `main` y aplica las migraciones al arrancar.
- Modo mixto: Claude escribe reglas de negocio y algoritmos con tests y revisa; Codex hace el cableado
  (persistencia, importador, UI repetitiva).
- Tests: `dotnet test tests/Mismade.Tests` (SQLite en memoria; ver `ArtifactImporterTests` para el
  truco de la columna `xmin`). El export real se prueba localmente con la variable `MISMADE_EXPORT`.

## 5. Tareas pendientes, en orden

Cada tarea termina con build sin warnings, tests en verde y, si cambia el comportamiento en producción,
una verificación en pantalla después del deploy. Ninguna de las tareas 1 a 5 escribe en Tiendanube.

### Tarea 1 — Importador: bloqueo de seguridad y colecciones faltantes (hecha)
Validada localmente con build sin warnings y tests, incluyendo export 1 + export 2 con rollback
y conteos contra los archivos. Migración `DesacoplesYVariantesPrendas` generada; sin deploy ni reimportación en Neon.
- **Bloqueo:** antes de escribir, leer el último `JobRun` exitoso y abortar si su `Detalle` no tiene
  `ModoSombra = true`. Mensaje claro: "El panel no está en modo sombra; no importo".
- **Colecciones nuevas** (del export 2), con migración:
  - Desacoples de remeras: tabla `StockDesacople` (PoolKey, StockAtDecouple, AutoCreated, Reason, CreatedAt).
  - Variantes de buzos y pantalones: tabla nueva o generalizar `StockConjuntoVariant` a "variante de
    prenda" (Tipo, Color, Talle, ProductId, VariantId).
  - Watermark y último enviado de buzos/pantalones/conjuntos y del pool manual (claves propias en
    `SyncWatermark`, `StockManualPoolWatermark` y `LastPushedStock`).
- **Modo reemplazo** para el cutover: hoy el importador exige tablas vacías. Hace falta una opción
  `--reemplazar` que, en una transacción, borre las tablas del artifact y vuelva a importar. Las ventas
  de Tiendanube, Meta, usuarios y conexión **no se tocan**.
- **Criterio de aceptación:** prueba sin `--confirmar` con export 1 + export 2 juntos; conteos iguales a
  los archivos; test de que aborta si el último run no está en modo sombra.

### Tarea 2 — Desacople de remeras en el algoritmo (`Domain/StockSync.cs`) — HECHA 11/10
Implementada en `StockSync.Desacoplar`, persistida en `StockDesacople` y probada en `StockDesacopleTests`.
Dos decisiones explícitas: (1) un pool desacoplado cuyo último enviado no es 0 se corrige enviando 0 (el
artifact supone que ya está en 0; es el caso del incidente); (2) una carga que supera `stock_at_decouple`
pero deja el pool en 1 a 3 lo mantiene desacoplado con el nuevo valor (lectura secuencial del artifact).
Neon se realineó con el artifact el 11/10 (`--reemplazar` con export-mismade-3, watermark #1789).
Reglas exactas (sección 3.7 de reglas-artifact.md):
- Si un pool **no** está desacoplado y después de descontar queda en 1, 2 o 3: crear desacople con
  `stock_at_decouple` = ese stock, `auto_created = true`, y **publicar 0**.
- Mientras esté desacoplado: publicar siempre 0 y dejar el último enviado en 0, aunque el stock real cambie.
- **Reactivación:** si el stock real supera estrictamente a `stock_at_decouple` (carga de mercadería),
  borrar el desacople y publicar el valor real.
- En 0 real no se desacopla (ya está en 0 en los dos lados).
- **Solo remeras.** Buzos, pantalones, conjuntos y pool manual nunca se desacoplan.
- **Tests con casos reales:** beige_regular_xl en 3 → publica 0; estando desacoplado baja a 2 → sigue
  en 0 y no se envía; carga que lo sube a 4 → se reactiva y publica 4; pool en 4 que vende 1 → queda en
  3, se desacopla, publica 0.

### Tarea 3 — Sync de buzos, pantalones y conjuntos
Reglas (sección 3.11):
- Pools por color/talle (todo Oversize), con variantes propias y watermark propio.
- Una venta de **conjunto** descuenta 1 del buzo **y** 1 del pantalón del mismo color/talle. El artifact
  los reconoce por nombre de producto ("Conjunto Oversize Básico <color>") + talle; nosotros tenemos sus
  variant_id en `StockConjuntoVariant`, así que se matchea por variante.
- Stock publicado del conjunto = `min(buzo, pantalón)`.
- Sin desacople ni piso preventivo: se publica el real hasta llegar a 0.
- Tests: venta de conjunto descuenta los dos; conjunto publica el mínimo; buzo en 1 se sigue publicando 1.

### Tarea 4 — Movimientos manuales (`TODO 6`) y formularios de carga
- Formularios en el Blazor para: ventas en negro (remera/buzo/pantalón), pérdida de mercadería,
  movimientos con Cris (pago/devolución/compra), cambios de prendas, carga al stock de cambios y venta
  de prenda de cambio. Mismos campos que el artifact (ver el export).
- Efecto en stock **al guardar**, igual que el artifact: venta en negro de remera, pérdida, devolución a
  Cris y prenda que sale en un cambio restan de `StockRemeras`; venta en negro de buzo solo resta si es
  Negro XXL Regular (pool manual); prenda que vuelve en un cambio suma a `StockCambios`; venta de prenda
  de cambio resta de `StockCambios`.
- El diff contra el último enviado ya hace que la próxima corrida "vea" esos cambios.
- Al borrar un movimiento, revertir su efecto en stock (definir con Lucas si hace falta; el artifact
  permite borrar filas).

### Tarea 5 — Margen real e historial (`TODO 2, 3, 8` y `FinanzasConsulta`)
- Por pedido de Tiendanube: ingreso − comisión − envío absorbido − costo de mercadería; por período:
  − ads de Street + ajustes de ventas en negro, pérdidas y ventas de prendas de cambio.
- **Discrepancias a corregir en `Reglas.cs` frente a la especificación** (verificar cada una):
  1. **Costo de mercadería de pedidos de Tiendanube:** el artifact usa un valor combinado
     prenda+estampado: remera $10.000, buzo/hoodie $24.500, pantalón/jogging $20.000, baby tee $6.500,
     conjunto $44.500. `CostoPrenda` tiene la tabla "solo prenda" (Negro Regular $7.500, etc.), que el
     artifact usa **solo** para ventas en negro y pérdidas. Hacen falta las dos tablas.
  2. **Nombres de medio de pago:** el artifact recibe "Mercado Pago", "Pago Nube", "GOcuotas",
     "Personalizado". `ComisionMedioPago` compara contra "mercadopago" y "pagonube" sin espacios:
     verificar cómo llega el gateway desde Tiendanube y normalizar.
  3. **Medio de pago desconocido:** el artifact no resta nada y deja una nota; el código tira excepción.
  4. **Envío absorbido:** el artifact dice "total ≥ umbral"; el código usa "total > umbral".
- Pago Nube por encima del umbral: usar el estado de `PagoNubeCuotas` (cuotas 23,03%, simple o
  pendiente 5,48%) y crear el registro "pending" para pedidos nuevos. Falta la pantalla donde Lucas los
  marca.
- Cierre de mes en `MonthlyHistory` (una sola vez por mes, con los campos de ajuste trazables).
- **Validación:** comparar ayer, últimos 7 días y mes en curso contra el artifact; deben coincidir.

### Tarea 6 — Meta Ads y página Campañas
- El dueño carga en Render `Meta__SystemUserToken`, `Meta__StreetAccountId`, `Meta__KumoAccountId`
  (pasos en DEPLOY.md). Cuentas: Street 211187655655565, Kumo 1524963622555289.
- Página Campañas con gasto, ROAS y compras de ayer, hoy y 7 días, **Street y Kumo siempre separados**.

### Tarea 7 — Clientes / ranking
Ranking de franquicias y clientes por compras desde las ventas guardadas.

## 6. Cutover (el día del cambio)

Solo cuando las tareas 1 a 5 estén hechas y los números coincidan con el artifact varios días seguidos.

1. Coordinar con Lucas una hora sin ventas manuales en curso.
2. Lucas **desactiva la tarea programada** del artifact (no la borra: queda como plan B).
3. El Claude de Lucas exporta **todas** las colecciones (lista completa en reglas-artifact.md).
4. Importar con `--reemplazar` (con el bloqueo de modo sombra activo) y verificar conteos y la página Stock.
5. Correr "Sincronizar ahora" en modo sombra y revisar las combinaciones que se enviarían: tienen que
   ser pocas y explicables (pedidos entre el export y ahora). Si aparece algo raro, frenar.
6. Recién ahí cargar `Stock__EnviarATiendanube=true` y sincronizar una vez mirando el resultado.
7. Lucas pasa a usar solo el panel de Render. La PC se puede apagar.
8. **Plan B:** volver a `false`, Lucas reactiva su tarea y fuerza el reenvío de todos los pools.
