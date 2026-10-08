{# MocksModified: preview opt-in; no cambia el producto ni sus imágenes cargadas.
   Agregar una clave con el nombre anterior a -<hash>-<tamaño>.webp del CDN.
   Dentro de esa clave, agregar cada set y su archivo con static_url.
   Agregar la etiqueta del set en labels; guardar archivos en static/images/mocks/.
   Ejemplo: 'otra-imagen': { 'oscuro': 'images/mocks/otra-imagen-oscuro.webp' | static_url }
#}
{% set mocks_modified = {
  'images': {
    'red-bull-1-dorso': {
      'oscuro': 'images/mocks/red-bull-1-dorso-oscuro.webp' | static_url
    }
  },
  'labels': {
    'oscuro': 'Fondo oscuro'
  }
} %}
<div data-module="MocksModified" data-config="{{ mocks_modified | json_encode | escape }}"></div>
