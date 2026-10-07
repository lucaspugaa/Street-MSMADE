{#
  Reset Password Section
  Form for customers to request a password reset email.
#}

{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="reset-form-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">
      <div class="account-form-subtitle">{{ 'password.send_email_info' | t }}</div>

      {% if success %}
        <div class="alert alert-success">{{ 'password.email_sent' | t | replace('{1}', email) }}</div>
      {% endif %}

      {% embed "snippets/forms/form.tpl" with{form_id: 'resetpass-form', submit_custom_class: 'btn-block', submit_text: 'password.send_email' | t } %}
        {% block form_body %}
          {% embed "snippets/forms/form-input.tpl" with{type_email: true, input_for: 'email', input_value: email, input_name: 'email', input_id: 'email', input_label_text: 'account.email' | t, input_placeholder: 'password.email_placeholder' | t } %}
            {% block input_label_text %}{{ 'account.email' | t }}{% endblock input_label_text %}
            {% block input_form_alert %}
              {% if failure %}
                <div class="account-form-alert alert alert-danger">{{ 'password.email_not_found' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}
        {% endblock %}
      {% endembed %}
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.reset_form",
  "class": "section section-main-reset",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.reset_form"}],
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
    "page_templates": ["account/reset"]
  }
}
{% endschema %}
