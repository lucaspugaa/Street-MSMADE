{#
  Page Content Section
  Renders static page content from the CMS.
#}

{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="page-content-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="page-content user-content">
      {{ page.content }}
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.page_content",
  "class": "section section-main-page",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.page_content"}],
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "section_width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "page", "label": "t:options.page" },
        { "value": "full", "label": "t:options.full" }
      ],
      "default": "page"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 0,
      "icon": "vertical_padding"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_padding",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "blocks": [],
  "enabled_on": {
    "page_templates": ["page"]
  }
}
{% endschema %}
