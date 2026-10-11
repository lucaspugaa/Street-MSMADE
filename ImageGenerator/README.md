# Generador de mockups

Usá fotos de prendas con fondo liso para verlas sobre otro fondo. Todo se procesa en tu computadora.

## Para empezar

Necesitás Windows y Node.js **24.15 o más nuevo**. Abrí una terminal dentro de `ImageGenerator/` y ejecutá:

```powershell
npm install
npm start
```

Abrí **http://127.0.0.1:4173**. Cargá varias fotos o arrastralas al recuadro. Elegí una imagen de fondo, un color o un degradado y tocá **Generar**. Vas a ver cada original junto a su resultado. Para aplicar cambios, tocá Generar otra vez o Regenerar en una tarjeta. Descargá cada WebP o usá Descargar todas (permití varias descargas si tu navegador lo pide).

El servidor escucha únicamente en tu computadora. Para cambiar el puerto, ejecutá `$env:PORT=4174` antes de `npm start`. Para cerrarlo, presioná Ctrl+C en la terminal.

## Carpeta destino

En la vista, editá **Carpeta destino** con una ruta absoluta (por ejemplo, `D:\Proyectos\Street-MSMADE\ImageGenerator\salida`). Al generar, el servidor crea la carpeta si hace falta, recuerda la ruta en `config.json` y guarda cada WebP allí. También conserva la vista previa y las descargas del navegador. Si un nombre ya existe, agrega un sufijo numérico sin sobrescribirlo.

La configuración es local y está en `.gitignore`. `GET /api/config` devuelve la ruta; `POST /api/config` recibe `{ "destino": "ruta absoluta" }`. El pedido de generación admite `destino` y `nombre` además de los campos originales; devuelve el WebP y la ruta guardada en `X-Saved-Path` (codificada como URI).

## Recorte

El selector permite usar **preciso** (modelo local, valor inicial) o **rápido** (color). Se recuperaron también los ajustes de rellenar mordidas y suavizar contorno. En el modo rápido el fondo se estima localmente desde los cuatro bordes, y la expansión de la sombra frena ante saltos de color para conservar el filo de las prendas crema. Los ajustes de rellenar mordidas y suavizar contorno actúan en el modo rápido.

## Usarlo desde la terminal

```powershell
node cli.mjs "mis fotos/"
node cli.mjs foto.png otra.jpg --color "#1c1c1c" --salida "resultados/"
node cli.mjs "mis fotos/" --fondo fondo.jpg --opciones opciones.json
npm run generar -- foto.png
```

La CLI procesa los PNG, JPG/JPEG y WebP de cada carpeta indicada, sin entrar en subcarpetas. Guarda `<nombre>-mock.webp` en `salida/` por defecto. Informa OK o error por archivo y sigue con los demás; devuelve un código de salida 1 si hubo errores. Archivos con el mismo nombre base comparten el destino y se reemplazan. Elegí `--fondo` o `--color`, no ambos; tienen prioridad sobre el fondo del JSON.

Podés crear `opciones.json` con solamente los ajustes que querés cambiar, por ejemplo:

```json
{
  "fondo": { "degradado": ["#3a3a3a", "#141414"] },
  "ancho": 1200,
  "alto": 1500,
  "escala": 0.78,
  "sombra": false
}
```

## Qué hace cada opción

Los valores iniciales vienen del generador; la pantalla los carga al abrirse.

| Opción | Para qué sirve y rango permitido |
| --- | --- |
| `fondo` | Color `#rrggbb` o degradado `[centro, borde]`. La pantalla y `--fondo` también aceptan una imagen. |
| `ancho`, `alto` | Tamaño de salida en píxeles, enteros entre 32 y 4096. |
| `escala` | Tamaño relativo de la prenda, entre 0.01 y 1. |
| `posicion_vertical` | Ubicación vertical: 0 arriba, 0.5 centro, 1 abajo. |
| `tolerancia` | Cuánta diferencia de color se considera fondo, entre 0 y 255. Bajala si se pierde parte de la prenda. |
| `recortar_borde` | Píxeles que se quitan del contorno para limpiar restos, entero entre 0 y 20. |
| `borde_suave` | Suavizado del contorno, entre 0 y 100; 0 lo desactiva. |
| `sombra_original` | `true` conserva la sombra de la foto; `false` la desactiva. |
| `quitar_huecos` | `true` quita zonas cerradas del color del fondo; `false` las conserva. |
| `sombra` | `false` la desactiva; un objeto permite ajustar la sombra agregada. |
| `sombra.opacidad` | Intensidad entre 0 y 1. |
| `sombra.desenfoque` | Suavizado entre 0 y 200; 0 lo desactiva. |
| `sombra.x`, `sombra.y` | Desplazamiento horizontal y vertical en píxeles, entre -4096 y 4096. |

## Límites conocidos

- Los collages y las fotos sin fondo liso dan error. Las prendas blancas sobre fondo blanco pueden recortarse mal.
- Se acepta una imagen por pedido, PNG/JPEG/WebP sin animación, hasta 40 megapíxeles. La pantalla las envía de a una.
- Cada pedido admite hasta 25 MB de JSON, incluyendo la foto y el fondo en base64 (ocupan más que los archivos originales).
- El fondo de imagen se ajusta para cubrir la salida; puede recortarse en los bordes.
- Cambiar un ajuste no vuelve a generar automáticamente. Las descargas múltiples son individuales, sin ZIP.
