{# Page Header Section #}
{# Reusable section for page headers with breadcrumbs and dynamic title #}
{# Can be used in category, search, contact, blog, etc. #}

{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(32) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding | default(32) %}

{# Colors #}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}


{% if template == 'account/order' %}
  {{ component('nubesdk-slot', { type: "before_account_order_header" }) }}
{% endif %}

<div
  class="page-header"
  data-store="page-title"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px; {% if background_color %}background-color: {{ background_color }};{% endif %} {% if text_color %}color: {{ text_color }};{% endif %}"
>
  {% if page_width %}
    <div class="container {% if template == 'blog-post' %}container-narrow{% endif %}">
  {% endif %}

        <div class="page-header-title-row">
          <div>
            {% include 'snippets/breadcrumbs.tpl' %}

            {% set passwordless_template = template == 'account/login' and store_has_passwordless_login and not params.fallback %}
            <div class="page-header-title-inner">
              <h1 class="{{ passwordless_template ? 'js-passwordless-login-header-title' }} page-header-title" {% if passwordless_template %}style="visibility: hidden;"{% endif %}>
                {% if template == 'category' %}
                  {{ category.name }}
                {% elseif template == 'search' %}
                  {% if products or has_applied_filters or not has_products %}
                    {{ 'search.search_results' | t }}
                  {% else %}
                    {{ 'search.no_results_for' | t }} "{{ query }}"
                  {% endif %}
                {% elseif template == 'contact' %}
                  {{ 'general.contact' | t }}
                {% elseif template == 'blog' %}
                  {{ 'general.blog' | t }}
                {% elseif template == 'page' %}
                  {{ page.name }}
                {% elseif template == 'cart' %}
                  {{ 'general.shopping_cart' | t }}
                {% elseif template == 'blog-post' %}
                  {{ post.title }}
                {% elseif template == 'account/login' %}
                  {{ 'general.login_page' | t }}
                {% elseif template == 'account/register' %}
                  {{ 'general.create_account' | t }}
                {% elseif template == 'account/reset' %}
                  {{ 'general.recover_password' | t }}
                {% elseif template == 'account/newpass' %}
                  {% if action == 'account_activation' %}
                    {{ 'general.activate_account_title' | t }}
                  {% else %}
                    {{ 'general.change_password_title' | t }}
                  {% endif %}
                {% elseif template == 'account/orders' %}
                  {{ 'general.my_account_title' | t }}
                {% elseif template == 'account/order' %}
                  {% if is_subscription %}
                    {{ subscription.id }}
                  {% else %}
                    {{ 'general.order_title' | t }} #{{ order.number }}
                  {% endif %}
                {% elseif template == 'account/info' %}
                  {{ 'general.my_info' | t }}
                {% elseif template == 'account/addresses' %}
                  {{ 'general.my_addresses_title' | t }}
                {% elseif template == 'account/address' %}
                  {% if address %}
                    {{ 'general.edit_address' | t }}
                  {% else %}
                    {{ 'general.new_address' | t }}
                  {% endif %}
                {% elseif template == 'account/subscription-address' %}
                  {{ 'subscriptions.customer_subscriptions.address_page_title' | t }}
                {% endif %}
              </h1>
              {% if (template == 'category' or template == 'search') and products | length > 1 %}
                <div class="page-header-count d-block d-md-none">
                  {{ products_count }} {{ 'general.products_label' | t }}
                </div>
              {% endif %}
            </div>

            {% if template == 'category' and category.description %}
              <p class="page-header-description">{{ category.description }}</p>
            {% endif %}
          </div>

        </div>

  {% if page_width %}
    </div>
  {% endif %}
</div>

{% if template == 'account/order' %}
  {{ component('nubesdk-slot', { type: "after_account_order_header" }) }}
{% endif %}


{% schema %}
{
  "name": "t:names.header",
  "class": "section section-page-header",
  "limit": 1,
  "deletable": false,
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
      "default": 32,
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
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "background_color",
      "label": "t:content.background",
      "default": "transparent"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    }
  ],
  "blocks": [],
  "enabled_on": {
    "page_templates": [
      "category",
      "search",
      "contact",
      "blog",
      "blog-post",
      "page",
      "cart",
      "account/login",
      "account/register",
      "account/reset",
      "account/newpass",
      "account/orders",
      "account/order",
      "account/info",
      "account/addresses",
      "account/address",
      "account/subscription-address"
    ]
  },
  "presets": [
    {
      "name": "t:names.heading"
    }
  ]
}
{% endschema %}
