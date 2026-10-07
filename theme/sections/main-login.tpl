{#
  Login Section
  Customer login form with optional social login.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="login-form-section"
  data-store="login-form"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">
      {% if store_has_passwordless_login and not params.fallback %}
        {{ component('forms/login-passwordless', {
            form_classes: {
                label_skeleton:  'placeholder placeholder-line placeholder-shine',
                input_skeleton:  'placeholder placeholder-line placeholder-line-medium placeholder-shine',
                button_skeleton: 'placeholder placeholder-line placeholder-line-big placeholder-shine',
            }
        }) }}
      {% else %}
        {% include 'snippets/forms/login.tpl' %}
      {% endif %}
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.login_form",
  "class": "section section-main-login",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.login_form"}],
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
    "page_templates": ["account/login"]
  }
}
{% endschema %}
