{# MSMADE · Punto de montaje de un módulo JS que no tiene HTML propio (o contenedor vacío, sin módulo).
   Reemplaza a un bloque de código que solo traía <style>/<script>: deja el mismo contenedor vacío en el mismo
   lugar del DOM, así src/main.js inicializa los módulos en el mismo orden en que corrían los scripts originales. #}

{% set module_name = block.settings.module %}

{# Sin módulo también se renderiza: el contenedor vacío ocupa su lugar en el flex (gap) igual que el bloque original. #}
<div class="code-block block-fill" {{ block | block_attributes }} data-store="code-block-{{ block.id }}"{% if module_name %} data-module="{{ module_name }}"{% endif %}></div>

{% schema %}
{
  "name": "Módulo JS",
  "tags": ["general"],
  "icon": "CodeIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "select",
      "id": "module",
      "label": "Módulo",
      "options": [
        { "value": "", "label": "Ninguno (solo contenedor)" },
        { "value": "LandingPage", "label": "Home · universos y más vendidos" },
        { "value": "StoreTheme", "label": "Global · paletas, menú y premios" },
        { "value": "MiniCart", "label": "Global · carrito mini" },
        { "value": "DesignMocks", "label": "Global · comparador de diseños (editor)" }
      ],
      "default": ""
    }
  ]
}
{% endschema %}
