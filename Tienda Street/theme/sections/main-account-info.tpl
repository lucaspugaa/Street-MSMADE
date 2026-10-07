{#
  Account Info Section
  Form to edit customer profile (name, email, etc.).
#}
{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="account-info-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">
      {% embed "snippets/forms/form.tpl" with{form_id: 'info-form', submit_custom_class: 'btn-block', submit_text: 'account.save_changes' | t } %}
        {% block form_body %}
          {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'name', input_value: result.name | default(customer.name), input_name: 'name', input_id: 'name', input_label_text: 'account.name' | t } %}
            {% block input_form_alert %}
              {% if result.errors.name %}
                <div class="notification-danger notification-left">{{ 'account.name_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-input.tpl" with{type_email: true, input_for: 'email', input_value: result.email | default(customer.email), input_name: 'email', input_id: 'email', input_label_text: 'account.email' | t } %}
            {% block input_form_alert %}
              {% if result.errors.email == 'exists' %}
                <div class="notification-danger notification-left">{{ 'account.email_taken_error' | t }}</div>
              {% elseif result.errors.email %}
                <div class="notification-danger notification-left">{{ 'account.email_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-input.tpl" with{type_tel: true, input_for: 'phone', input_value: result.phone | default(customer.phone), input_name: 'phone', input_id: 'phone', input_label_text: 'account.phone_optional' | t } %}
          {% endembed %}
        {% endblock %}
      {% endembed %}
      <p class="account-form-help">{{ 'account.change_password' | t | a_tag(store.customer_reset_password_url, '', 'btn-link') }}</p>
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.account_info",
  "class": "section section-main-account-info",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.account_info"}],
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
    "page_templates": ["account/info"]
  }
}
{% endschema %}
