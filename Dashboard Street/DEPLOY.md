# Deploy paso a paso

Todo lo que se puede automatizar ya está en el repo. Lo que queda son las altas de cuentas y copiar valores entre paneles.

| Archivo | Para qué |
|---|---|
| `../render.yaml` | Blueprint de Render: crea el servicio con Docker, health check y variables. |
| `railway.json` | Config de Railway para cuando pases a pago. |
| `../.github/workflows/dashboard-ci.yml` | En cada push: build, tests y una prueba del contenedor contra Postgres real. |
| `../.github/workflows/dashboard-sync.yml` | Disparador del job desde GitHub (alternativa a cron-job.org). |

## Plan free (Render + Neon)

### 1. Base de datos en Neon
1. Creá la cuenta en https://neon.tech y un proyecto `mismade`, región **AWS US East** (N. Virginia u Ohio; el servicio de Render está en Virginia y entre las dos hay pocos milisegundos).
2. En **Connect**, desactivá **Connection pooling** (el job usa advisory locks de sesión y el pooler no los respeta).
3. Armá la cadena con esos datos:
   `Host=<host>;Database=<db>;Username=<user>;Password=<pass>;SSL Mode=Require`

### 2. App en Render
1. Creá la cuenta en https://render.com con tu GitHub y dale acceso al repo `Street-MSMADE`.
2. **New > Blueprint**, elegí el repo. Render lee `render.yaml`.
3. Completá lo que pide:
   - `ConnectionStrings__Default`: la cadena de Neon.
   - `Seed__OwnerUser` y `Seed__OwnerPassword`: el usuario de Lucas. La clave necesita mayúscula, minúscula, número y símbolo.
   - `Tiendanube__AppId` y `Tiendanube__ClientSecret`: de la app creada en Partners (ver abajo).
   - `Tiendanube__UserAgent`: nombre de la app y email o URL de contacto; default `MISMADE Dashboard`.
   - `Tiendanube__StoreId` y `Tiendanube__AccessToken`: opcionales; juntos reemplazan las credenciales guardadas por OAuth.
   - Meta: podés dejar sus variables vacías hasta implementar esa integración.
4. Esperá el primer deploy y entrá a `https://<servicio>.onrender.com`. Iniciá sesión con el Owner.
5. En **Environment**, borrá `Seed__OwnerPassword` (ya no se usa).

### Conexión de Tiendanube
1. En [partners.tiendanube.com](https://partners.tiendanube.com), creá la app.
2. Configurá el redirect de instalación como `https://<servicio>.onrender.com/tiendanube/callback`.
3. Habilitá los scopes `read_orders`, `read_products`, `write_products`.
4. Copiá el AppId y ClientSecret a `Tiendanube__AppId` y `Tiendanube__ClientSecret` en Render > Environment.
5. Entrá al dashboard como Owner y pulsá **Conectar Tiendanube**. Autorizá la tienda; Inicio confirma la conexión.

El token se guarda cifrado en PostgreSQL junto con las claves de Data Protection. No copies tokens ni secretos al repo.
La cookie OAuth es HttpOnly, Secure, SameSite=Lax y vence a los diez minutos; usá HTTPS.
La actualización batch de stock está prevista para un único depósito; múltiples depósitos necesitan IDs de ubicación.

### 3. Disparador del job (elegí uno)
**cron-job.org** (más puntual):
1. Cuenta en https://cron-job.org.
2. Dos jobs: URL `https://<servicio>.onrender.com/jobs/sync`, método **POST**, header `X-Job-Key` con el valor de `Jobs__Key` (lo ves en Render > Environment). Horarios 00:01 y 18:01, zona `America/Argentina/Buenos_Aires`. Timeout al máximo.

**GitHub Actions** (sin cuenta nueva, pero puede atrasarse unos minutos):
1. En el repo: Settings > Secrets and variables > Actions.
2. Variables `SYNC_TRIGGER=github` y `DASHBOARD_URL=https://<servicio>.onrender.com`; secret `JOBS_KEY` con el valor de `Jobs__Key`.
3. Probalo con Actions > Dashboard sync trigger > Run workflow.

## Pasar a pago

### Railway
1. Cuenta en https://railway.com, **New Project > Deploy from GitHub repo**.
2. En el servicio: Settings > **Root Directory** = `Dashboard Street` y **Config file** = `/Dashboard Street/railway.json`.
3. Variables: copiá las mismas de Render y cambiá `Jobs__Mode=Hangfire`. `Jobs__Key` ya no hace falta.
4. Base: podés seguir con Neon (no se mueve nada) o agregar Postgres en Railway y pasar los datos con `pg_dump` / `pg_restore`.
5. Settings > Networking > **Generate Domain**. Entrá a `/hangfire` y corré el job a mano para comparar.
6. Apagá el disparador (cron-job.org o la variable `SYNC_TRIGGER`) y suspendé el servicio de Render.

### Render Starter
En el servicio: **Upgrade** a Starter, cambiá `Jobs__Mode=Hangfire` y apagá el disparador.
