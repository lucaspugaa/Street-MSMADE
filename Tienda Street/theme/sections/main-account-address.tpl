{#
  Account Address Section
  Form to add or edit a customer address.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="account-address-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">
      {% if has_active_subscriptions %}
        <div class="alert alert-info">
          {{ 'subscriptions.customer_subscriptions.account_address_notice' | t }}
        </div>
      {% endif %}
      {% embed "snippets/forms/form.tpl" with{form_id: 'address-form', submit_custom_class: 'btn-block', submit_text: 'address.save' | t } %}
        {% block form_body %}
          {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'name', input_value: result.name | default(address.name), input_name: 'name', input_id: 'name', input_label_text: 'address.name_alias' | t, input_placeholder: 'address.name_placeholder' | t } %}
            {% block input_form_alert %}
              {% if result.errors.name %}
                <div class="notification-danger notification-left">{{ 'address.name_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% if current_language.country == 'BR' %}
            {% set address_placeholder = 'address.address_placeholder_br' | t %}
          {% else %}
            {% set address_placeholder = 'address.address_placeholder' | t %}
          {% endif %}
          
          {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'address', input_value: result.address | default(address.address), input_name: 'address', input_id: 'address', input_label_text: 'address.address' | t, input_placeholder: address_placeholder } %}
            {% block input_form_alert %}
              {% if result.errors.address %}
                <div class="notification-danger notification-left">{{ 'address.address_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% if current_language.country == 'BR' %}
            {% embed "snippets/forms/form-input.tpl" with{type_number: true, input_for: 'number', input_value: result.number | default(address.number), input_name: 'number', input_id: 'number', input_label_text: 'address.number' | t, input_placeholder: 'address.number_placeholder' | t } %}
              {% block input_form_alert %}
                {% if result.errors.number %}
                  <div class="notification-danger notification-left">{{ 'address.number_error' | t }}</div>
                {% endif %}
              {% endblock input_form_alert %}
            {% endembed %}

            {% embed "snippets/forms/form-input.tpl" with{type_number: true, input_for: 'floor', input_value: result.floor | default(address.floor), input_name: 'floor', input_id: 'floor', input_label_text: 'address.floor' | t } %}
              {% block input_form_alert %}
                {% if result.errors.floor %}
                  <div class="notification-danger notification-left">{{ 'address.floor_error' | t }}</div>
                {% endif %}
              {% endblock input_form_alert %}
            {% endembed %}

            {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'locality', input_value: result.locality | default(address.locality), input_name: 'locality', input_id: 'locality', input_label_text: 'address.locality' | t, input_placeholder: 'address.locality_placeholder' | t } %}
              {% block input_form_alert %}
                {% if result.errors.locality %}
                  <div class="notification-danger notification-left">{{ 'address.locality_error' | t }}</div>
                {% endif %}
              {% endblock input_form_alert %}
            {% endembed %}
          {% endif %}

          {% embed "snippets/forms/form-input.tpl" with{type_tel: true, input_for: 'zipcode', input_value: result.zipcode | default(address.zipcode), input_name: 'zipcode', input_id: 'zipcode', input_label_text: 'address.zipcode' | t, input_placeholder: 'address.zipcode_placeholder' | t } %}
            {% block input_form_alert %}
              {% if result.errors.zipcode %}
                <div class="notification-danger notification-left">{{ 'address.zipcode_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'city', input_value: result.city | default(address.city), input_name: 'city', input_id: 'city', input_label_text: 'address.city' | t, input_placeholder: 'address.city_placeholder' | t } %}
            {% block input_form_alert %}
              {% if result.errors.city %}
                <div class="notification-danger notification-left">{{ 'address.city_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-input.tpl" with{type_text: true, input_for: 'province', input_value: result.province | default(address.province), input_name: 'province', input_id: 'province', input_label_text: 'address.province' | t, input_placeholder: 'address.province_placeholder' | t } %}
            {% block input_form_alert %}
              {% if result.errors.province %}
                <div class="notification-danger notification-left">{{ 'address.province_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-select.tpl" with{select_for: 'country', select_name: 'country', select_id: 'country', select_label_name: 'address.country' | t } %}
            {% block select_options %}{{ country_options }}{% endblock select_options %}
            {% block input_form_alert %}
              {% if result.errors.country %}
                <div class="notification-danger notification-left">{{ 'address.country_error' | t }}</div>
              {% endif %}
            {% endblock input_form_alert %}
          {% endembed %}

          {% embed "snippets/forms/form-input.tpl" with{type_tel: true, input_for: 'phone', input_value: result.phone | default(address.phone), input_name: 'phone', input_id: 'phone', input_label_text: 'address.phone' | t, input_placeholder: 'address.phone_placeholder' | t } %}
            {% block input_form_alert %}
              {% if result.errors.phone %}
                <div class="notification-danger notification-left">{{ 'address.phone_error' | t }}</div>
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
  "name": "t:names.account_address",
  "class": "section section-main-account-address",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.account_address"}],
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
    "page_templates": ["account/address"]
  }
}
{% endschema %}
