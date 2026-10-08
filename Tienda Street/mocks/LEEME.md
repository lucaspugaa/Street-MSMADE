# Cambiar las portadas de preview con una planilla

La planilla es `mocks/productos.csv`. Cada fila es un producto. Completás la ubicación de una imagen y los comandos preparan el mock. No tenés que editar Twig ni cambiar el producto en Tiendanube.

## 1. Abrí la terminal en Tienda Street

Usá la terminal que ya tenés para este proyecto. Si está en otra carpeta, ejecutá:

```powershell
cd "D:\Proyectos\Street-MSMADE-tienda\Tienda Street"
```

La primera vez, si todavía no están instaladas las herramientas, ejecutá `npm install`. Necesitás Node 24.15 o posterior. Si el comando de productos pide el navegador local, ejecutá `npm exec playwright install chromium` una vez y volvé a intentar.

## 2. Actualizá la lista de productos

Cerrá la planilla en Excel y ejecutá:

```powershell
npm run mocks:productos
```

El comando lee el catálogo público como un visitante, con una pausa entre páginas. Usa la dirección de la tienda que ya está configurada localmente. No necesita iniciar sesión en la tienda.

Agrega productos nuevos, actualiza nombres y portadas actuales, y ordena por nombre. Conserva tus fondos y otras columnas. Un producto que ya no está en el catálogo queda en la planilla con `estado` = `no disponible`; no se borra su fila. Si falla la lectura o no puede confirmar el catálogo completo, no cambia la planilla.

## 3. Completá los fondos en Excel

Abrí `mocks/productos.csv` con Excel. El archivo usa UTF-8 con BOM y separador `;` para que se vean bien los acentos y las columnas en Excel en español.

| Columna | Qué hacer |
| --- | --- |
| `handle` | No cambiar: identifica al producto en su dirección web. |
| `producto` | Nombre para encontrarlo fácilmente. Se actualiza con el catálogo. |
| `portada_actual` | Dirección de la portada de la tienda, como referencia. No es la ruta del mock. |
| `fondo_oscuro` | Ubicación de la imagen que querés usar con fondo oscuro. Vacía = sin mock. |
| `estado` | `publicado` o `no disponible`, según la última lectura del catálogo. |

Copiá las imágenes a `mocks/imagenes/`. En la celda del fondo escribí, por ejemplo:

```text
imagenes/mi-remera-oscura.png
```

También podés pegar una ruta completa, por ejemplo `C:\Users\TuNombre\Pictures\mi-remera.jpg`. La ruta no lleva comillas alrededor, aunque tenga espacios. Las rutas relativas se cuentan desde la carpeta de la planilla, `mocks/`. El mock de Red Bull ya está cargado como ejemplo y su imagen de origen está en `mocks/imagenes/`.

Formatos permitidos: PNG, JPG, JPEG y WebP. Recomendado: al menos 800 píxeles de ancho. Si es más chica, el comando avisa y la usa igual. Si es más grande que 1600 píxeles, prepara una versión de hasta 1600 para que cargue más liviana. Nunca agranda una imagen chica ni modifica tu archivo de origen.

Para otro fondo, agregá una columna como `fondo_crema` o `fondo_azul_claro`. El control de preview mostrará “Fondo crema” o “Fondo azul claro”. Podés dejar celdas vacías en los productos que no tengan ese fondo.

Guardá como **CSV UTF-8**, manteniendo el separador **punto y coma (`;`)**, y cerrá Excel antes del siguiente paso. No guardes como XLSX. Si Excel muestra todo en una sola columna, importá desde Datos → Desde texto/CSV, elegí UTF-8 y delimitador punto y coma.

## 4. Prepará los mocks

```powershell
npm run mocks:aplicar
```

El comando valida las rutas, convierte las imágenes, genera el mapa y compila el tema. Al terminar muestra cuántos mocks aplicó, cuántos no cambiaron y cuántos tuvieron error.

Si una ruta no existe o una imagen está dañada, no cambia ni borra ningún mock: corregí la celda indicada y repetí. Si Excel tiene el archivo abierto y el comando no puede guardarlo, cerralo y repetí.

Los resultados van a `theme/static/images/mocks/<handle>-<fondo>.webp`. Esa carpeta y `theme/snippets/mocks-modified.tpl` son generadas: no las edites ni guardes allí las únicas copias de tus imágenes. Al vaciar una celda y volver a aplicar, se elimina su mock generado. Los archivos de origen en `mocks/imagenes/` se conservan. El campo `estado` es informativo: los fondos completados se conservan y se preparan aunque el producto ya no esté disponible.

## 5. Subí a la copia y revisá

Este paso lo ejecutás vos cuando quieras revisar los cambios en la tienda:

```powershell
npm run mocks:subir
```

Primero muestra las diferencias. Después inicia la subida a **TEST (Copia), tema 14597412**, y deja la confirmación interactiva de la herramienta para que revises y respondas. Si no querés continuar, cancelá con Ctrl+C. Este comando no publica la tienda.

El comando sube los cambios locales del tema, no solamente las imágenes. Revisá las diferencias que muestra antes de confirmar.

Abrí la vista previa de TEST (Copia) que ya usás, en una ficha, categoría o búsqueda. Agregá `?mocks=oscuro` a la dirección; si ya tiene un `?`, agregá `&mocks=oscuro`. También podés usar `mocks=1` para elegir el primer fondo disponible.

En una ficha, el mock aparece primero y todas las fotos originales siguen después. En las tarjetas con slider también va primero; en las otras cambia la portada visible. La home y sus más vendidos no cambian. El botón **Original** vuelve a las portadas anteriores sin recargar.

La elección se recuerda durante esa sesión de navegación. Para apagarla, usá `mocks=0` de la misma manera. Sin activación ni selección recordada, la página conserva su aspecto habitual.
