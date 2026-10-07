{#
  New Password Section
  Form for setting a new password after reset or account activation.
#}
{% set is_account_activation = action == 'account_activation' %}

{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="newpass-form-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-form-container">
      {% if link_expired %}
        {% set contact_links = store.phone or store.email %}
        
        <div class="newpass-info-container">
          {% if is_account_activation %}
            <div class="newpass-info-title">{{ 'password.activate_link_expired' | t }}</div>
            <div class="newpass-info-text">{{ 'password.contact_us_new_link' | t }}</div>
          {% else %}
            <div class="newpass-info-title">{{ 'password.reset_link_expired' | t }}</div>
            <div class="newpass-info-text-spaced">{{ 'password.enter_email_new_link' | t }}</div>
            <a href="{{ store.customer_reset_password_url }}" class="btn-link">{{ 'password.enter_email' | t }}</a>
          {% endif %}
        </div>

        {% if contact_links and is_account_activation %}
          {% include "snippets/social/contact-links.tpl" with {with_icons: true, phone_and_mail_only: true} %}
        {% endif %}

      {% else %}
        {% if failure %}
          <div class="alert alert-danger">{{ 'password.passwords_not_match' | t }}</div>
        {% endif %}

        {% embed "snippets/forms/form.tpl" with{form_id: 'newpass-form', submit_custom_class: 'btn-block', submit_text: customer.password ? 'password.change_password' | t : 'password.activate_account' | t } %}
          {% block form_body %}
            {% embed "snippets/forms/form-input.tpl" with{type_password: true, input_for: 'password', input_name: 'password', input_id: 'password', input_label_text: 'password.password_label' | t } %}
            {% endembed %}

            {% embed "snippets/forms/form-input.tpl" with{type_password: true, input_for: 'password_confirm', input_name: 'password_confirm', input_id: 'password_confirm', input_label_text: 'password.confirm_password' | t } %}
            {% endembed %}
          {% endblock %}
        {% endembed %}
      {% endif %}
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.newpass_form",
  "class": "section section-main-newpass",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.newpass_form"}],
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
    "page_templates": ["account/newpass"]
  }
}
{% endschema %}
