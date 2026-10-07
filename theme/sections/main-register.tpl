{#
  Register Section
  Customer registration form with optional social login.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="register-form-section"
  data-store="register-form"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">

      {{ component('nubesdk-slot', { type: "before_register_form" }) }}

      <div class="account-form-subtitle">{{ 'general.register_subtitle' | t }}</div>

      {% include 'snippets/forms/register.tpl' %}

      {{ component('nubesdk-slot', { type: "after_register_form" }) }}

    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.register_form",
  "class": "section section-main-register",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.register_form"}],
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
  "enabled_on": {
    "page_templates": ["account/register"]
  }
}
{% endschema %}
