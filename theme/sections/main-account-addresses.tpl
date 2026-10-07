{#
  Account Addresses Section
  Customer address list with main and additional addresses.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="account-addresses-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-page-content account-page-sidebar-wide">
      {% for address in customer.addresses %}
        {% if loop.first %}
          <div>
            <h6 class="account-section-title">{{ 'account.main_address' | t }}</h6>
        {% elseif loop.index == 2 %}
          <div class="account-addresses-grid">
            <h6 class="account-section-title">{{ 'account.other_addresses' | t }}</h6>
            <div class="account-addresses-card-grid">
        {% endif %}
              {% if not loop.first %}
                <div class="account-address-card card">
              {% endif %}
                  <div class="account-address-name">{{ address.name }} {{ 'account.edit' | t | a_tag(store.customer_address_url(address), '', 'account-address-edit btn-link') }}</div>
                  <div class="account-address-text">{{ address | format_address }}</div>
              {% if not loop.first %}
                </div>
              {% endif %}
        {% if not loop.first and loop.last %}
              </div>
        {% endif %}
        {% if loop.first %} 
              <a class="account-address-link btn-link" href="{{ store.customer_new_address_url }}">{{ 'account.add_new_address' | t }}</a>
          </div>
        {% elseif loop.last %}
          </div>
        {% endif %}
      {% endfor %}
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.account_addresses",
  "class": "section section-main-account-addresses",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.account_addresses"}],
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
    "page_templates": ["account/addresses"]
  }
}
{% endschema %}
