# MISMADE / Street

Esqueleto de dashboard interno en .NET 10 y Blazor Server. Requiere SDK 10.0.400 y PostgreSQL.

## Local

`docker compose up --build` inicia PostgreSQL 16 y la app en http://localhost:8080.
La app aplica la migración y crea los roles Owner y Operador al iniciar.
Sin Docker, usá PostgreSQL local y `dotnet run --project src/Mismade.Web --environment Development`.
Verificación: `dotnet build Mismade.sln` y `dotnet test Mismade.sln`.
Migraciones: `dotnet tool restore` y `dotnet ef migrations add Nombre --project src/Mismade.Infrastructure`.

## Variables

- `PORT`: 8080 por defecto.
- `ConnectionStrings__Default`: conexión Npgsql; para Neon usá host **directo**, base, usuario, contraseña y `SSL Mode=Require`. Los advisory locks son de sesión y no deben usar el pooler transaccional.
- `Jobs__Mode`: Endpoint (defecto) o Hangfire; `Jobs__Key`: clave del endpoint, vacía lo deshabilita.
- `Tiendanube__StoreId`, `Tiendanube__AccessToken`.
- `Meta__SystemUserToken`, `Meta__StreetAccountId`, `Meta__KumoAccountId`.
- `Seed__OwnerUser`, `Seed__OwnerPassword` (opcional `Seed__OwnerEmail`): crean el primer Owner solo si todavía no existe ninguno. Después de entrar la primera vez, borrá `Seed__OwnerPassword` del host; si lo dejás no pasa nada, porque nunca pisa un Owner existente. En local (Development y docker compose) el usuario es `owner` con la clave de `appsettings.Development.json`.

`POST /jobs/sync` con header `X-Job-Key` devuelve 202 al encolar. La cola Endpoint vive en memoria.
`/health` es público; las páginas requieren login y solo Owner puede sincronizar o abrir `/hangfire`.

## Hosting

El paso a paso (Render + Neon, disparador del job y paso a Railway) está en [DEPLOY.md](DEPLOY.md).

Para la opción gratuita, creá un Web Service Docker en Render y una base en Neon; configurá las variables anteriores sin guardar secretos en git. En cron-job.org configurá POST a `/jobs/sync`, header `X-Job-Key` y horarios 00:01 y 18:01 en America/Argentina/Buenos_Aires. El servicio gratuito de [Render se suspende por inactividad](https://render.com/docs/free): los arranques pueden demorar y un 202 no garantiza que una cola en memoria sobreviva a un reinicio.

Para pasar a pago, usá una instancia siempre activa y `Jobs__Mode=Hangfire`: agenda persistente `sync`, cron `1 0,18 * * *`, zona Argentina. Desactivá el cron externo. El Dockerfile usa la imagen oficial `aspnet:10.0` (Ubuntu), que ya trae las zonas horarias.

## Pendientes y decisiones

- Los diez pasos del job y las integraciones son TODO; Succeeded solo confirma la ejecución del esqueleto, todavía no sincroniza datos.
- El primer Owner se crea con `Seed__*` al arrancar; no hay registro público. Falta definir el alta de los demás usuarios (Operador).
- Se eligieron Id Guid, fechas de negocio DateOnly, auditoría UTC DateTimeOffset, textos para color/corte/talle/tipo de prenda y enums para estados.
- VentaNegroItem usa FK a VentaNegro y borrado cascade; los DTO externos son mínimos hasta implementar las APIs. Comisión devuelve monto decimal sin redondeo intermedio; medios/prendas desconocidos generan error.
- Umbral de comisión inyectable mediante proveedor de fecha, con valores históricos predeterminados. Conectar ConfigHistorica en el paso TODO de comisiones.
- Street y Kumo se procesarán por separado dentro del paso Meta; completar formularios, métricas e importador.
- Validar el contenedor y la integración real con PostgreSQL cuando Docker esté instalado.
