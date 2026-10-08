{# archivo generado por npm run mocks:aplicar, no editar a mano.
   Fuente: mocks/productos.csv. Clave: handle de /productos/<handle>/.
   Activar preview con ?mocks=1 o ?mocks=<set>; Original restaura las fotos.
#}
{% set mocks_modified = {
  'products': {
    'remera-oversize-red-bull-racing-v7yyp': {
      'oscuro': 'images/mocks/remera-oversize-red-bull-racing-v7yyp-oscuro.webp' | static_url
    }
  },
  'labels': {
    'oscuro': 'Fondo oscuro'
  }
} %}
<div data-module="MocksModified" data-config="{{ mocks_modified | json_encode | escape }}"></div>
