{#
  Password Section
  Password entry form to unlock a password-protected store.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="password-section-layout"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="password-form-wrapper">
      <div class="password-form-content">
        <h2 class="password-page-title">{{ message }}</h2>
        {% embed "snippets/forms/form.tpl" with{form_id: 'password-form', submit_text: 'general.unlock' | t, submit_custom_class: 'btn-block btn-big', form_custom_class: 'w-100' } %}
          {% block form_body %}
            {% embed "snippets/forms/form-input.tpl" with{input_for: 'password', type_password: true, input_name: 'password', input_label_text: 'general.access_password' | t, input_placeholder: 'general.password_placeholder' | t } %}
              {% block input_form_alert %}
                {% if invalid_password == true %}
                  <div class="account-form-alert alert alert-danger">{{ 'general.wrong_password' | t }}</div>
                {% endif %}
              {% endblock input_form_alert %}
            {% endembed %}
          {% endblock %}
        {% endembed %}
      </div>
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.password_content",
  "class": "section section-main-password",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.password_content"}],
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
    "page_templates": ["password"]
  }
}
{% endschema %}
