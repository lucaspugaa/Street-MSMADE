{# MocksModified: preview opt-in; no modifica productos ni imágenes en Tiendanube.
   Clave: handle del producto en /productos/<handle>/, independiente de sus fotos.
   Agregar cada set y su archivo con static_url dentro del handle; su etiqueta en labels.
   Guardar los archivos en static/images/mocks/.
   Ejemplo: 'otro-producto': { 'oscuro': 'images/mocks/otro-producto-oscuro.webp' | static_url }
   En ficha y sliders el mock es una portada adicional; Original conserva todas las fotos.
#}
{% set mocks_modified = {
  'products': {
    'remera-oversize-red-bull-racing-v7yyp': {
      'oscuro': 'images/mocks/red-bull-1-dorso-oscuro.webp' | static_url
    }
  },
  'labels': {
    'oscuro': 'Fondo oscuro'
  }
} %}
<div data-module="MocksModified" data-config="{{ mocks_modified | json_encode | escape }}"></div>
