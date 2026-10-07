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
1. Creá la cuenta en https://neon.tech y un proyecto `mismade`, región **AWS US East (N. Virginia)** (la misma que el servicio de Render).
2. En **Connect**, desactivá **Connection pooling** (el job usa advisory locks de sesión y el pooler no los respeta).
3. Armá la cadena con esos datos:
   `Host=<host>;Database=<db>;Username=<user>;Password=<pass>;SSL Mode=Require`

### 2. App en Render
1. Creá la cuenta en https://render.com con tu GitHub y dale acceso al repo `Street-MSMADE`.
2. **New > Blueprint**, elegí el repo. Render lee `render.yaml`.
3. Completá lo que pide:
   - `ConnectionStrings__Default`: la cadena de Neon.
   - `Seed__OwnerUser` y `Seed__OwnerPassword`: el usuario de Lucas. La clave necesita mayúscula, minúscula, número y símbolo.
   - Tiendanube y Meta: podés dejarlos vacíos hasta implementar esas integraciones.
4. Esperá el primer deploy y entrá a `https://<servicio>.onrender.com`. Iniciá sesión con el Owner.
5. En **Environment**, borrá `Seed__OwnerPassword` (ya no se usa).

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
