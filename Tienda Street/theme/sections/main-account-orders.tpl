{#
  Account Orders Section
  Customer account page with personal info and order history list.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="account-orders-section"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="account-page-content account-page-sidebar-wide">
      <div class="account-orders-sidebar">
        <div class="account-section-header">
          <h6 class="account-section-title">{{ 'account.personal_info' | t }}</h6>
          {{ 'account.edit' | t | a_tag(store.customer_info_url, '', 'btn-link') }}
        </div>
        {% set info_spacing = 'account-info-line' %}
        <div class="account-info-details">
          <div class="{{ info_spacing }}">
            {{ customer.name }}
          </div>
          <div class="{{ info_spacing }}">
            {{ customer.email }}
          </div>
          {% if customer.cpf_cnpj %}
            <div class="{{ info_spacing }}">
              {{ 'account.id_number' | t }}: {{ customer.cpf_cnpj | format_id_number(customer.billing_country) }}
            </div>
          {% endif %}
          {% if customer.business_name %}
            <div class="{{ info_spacing }}">
              {{ 'account.business_name' | t }}: {{ customer.business_name }}
            </div>
          {% endif %}
          {% if customer.trade_name %}
            <div class="{{ info_spacing }}">
              {{ 'account.trade_name' | t }}: {{ customer.trade_name }}
            </div>
          {% endif %}
          {% if customer.state_registration %}
            <div class="{{ info_spacing }}">
              {{ 'account.state_registration' | t }}: {{ customer.state_registration }}
            </div>
          {% endif %}
          {% if customer.business_activity %}
            <div class="{{ info_spacing }}">
              {{ 'account.business_activity' | t }}: {{ customer.business_activity }}
            </div>
          {% endif %}
          {% if customer.fiscal_regime %}
            <div class="{{ info_spacing }}">
              {{ 'account.fiscal_regime' | t }}: {{ customer.fiscal_regime | format_fiscal_regime }}
            </div>
          {% endif %}
          {% if customer.phone %}
            <div class="{{ info_spacing }}">
              {{ 'account.phone' | t }}: {{ customer.phone }}
            </div>
          {% endif %}
        </div>
        {% if customer.default_address %}
          <div class="account-section-header">
            <h6 class="account-section-title">{{ 'account.my_addresses' | t }}</h6>
            {{ 'account.edit' | t | a_tag(store.customer_address_url(customer.default_address), '', 'btn-link') }}
          </div>

          <div class="account-info-details">
            <div class="{{ info_spacing }}">
              {{ customer.default_address | format_address_short }}
            </div>
            {{ 'account.other_addresses' | t | a_tag(store.customer_addresses_url, '', 'btn-link') }}
          </div>
        {% endif %}
        <div class="account-logout-container">
          {{ 'account.logout' | t | a_tag(store.customer_logout_url, '', 'account-logout-link btn btn-link') }}
        </div>
      </div>
      <div data-store="account-orders">
        {% include 'snippets/subscriptions/subscription-list.tpl' %}
        {% if cancel_success %}
          <div class="alert alert-success ml-4">{{ 'order.cancel_success_message' | t }}</div>
        {% elseif cancel_error %}
          <div class="alert alert-danger ml-4">{{ 'order.cancel_error_message' | t | replace('{1}', customer.email) }}</div>
        {% endif %}
        {% if customer.orders %}
          {% if customer.ordersCount > 50 %}
            <div class="account-orders-heading">
              {{ 'account.last_50_orders' | t }}
            </div>
          {% endif %}
          <div class="account-orders-grid">
            {% for order in customer.orders %}
              {% set add_checkout_link = order.pending %}
              <div class="account-order-card" data-store="account-order-item-{{ order.id }}">

                {{ component('nubesdk-slot', { type: "before_account_order_item", pick: order.id }) }}

                {% embed "snippets/card.tpl" with{card_footer: true, card_custom_class: 'card-collapse', card_collapse: true} %}
                  {% block card_head %}
                    <div class="account-order-header-content">
                      <div class="account-order-number">
                        <a class="btn-link" href="{{ store.customer_order_url(order) }}"><strong>{{ 'account.order' | t }} #{{ order.number }}</strong></a>
                      </div>
                      <div class="js-card-collapse-toggle account-order-date">
                        {{ order.date | i18n_date('%d/%m/%Y') }}
                      </div>
                    </div>
                  {% endblock %}
                  {% block card_body %}
                    <div class="account-order-body">
                      <div class="account-order-status-container">
                        {% set status_classes = 'account-order-status' %}
                        {% set status_icon_classes = 'account-order-status-icon icon-inline' %}
                        <div class="{{ status_classes }}">
                          <svg class="{{ status_icon_classes }}"><use xlink:href="#credit-card"/></svg> {{ 'order.payment' | t }}: <span class="account-order-status-value {{ order.payment_status }}"><strong>{% if order.payment_status == 'pending' %}{{ 'order.payment_pending' | t }}{% elseif order.payment_status == 'authorized' %}{{ 'order.payment_authorized' | t }}{% elseif order.payment_status == 'paid' %}{{ 'order.payment_paid' | t }}{% elseif order.payment_status == 'voided' %}{{ 'order.payment_voided' | t }}{% elseif order.payment_status == 'refunded' %}{{ 'order.payment_refunded' | t }}{% else %}{{ 'order.payment_abandoned' | t }}{% endif %}</strong></span>
                        </div>
                        {% set shipping_status_label %}
                          {% if order.shipping_status == 'unpacked' %}
                            {{ 'order.shipping_unpacked' | t }}
                          {% elseif order.shipping_status == 'packed' %}
                            {{ 'order.shipping_packed' | t }}
                          {% elseif order.shipping_status == 'partially_packed' %}
                            {{ 'order.shipping_partially_packed' | t }}
                          {% elseif order.shipping_status == 'partially_fulfilled' %}
                            {{ 'order.shipping_partially_fulfilled' | t }}
                          {% elseif order.shipping_status == 'fulfilled' %}
                            {{ 'order.shipping_fulfilled' | t }}
                          {% elseif order.shipping_status == 'delivered' %}
                            {{ 'order.shipping_delivered' | t }}
                          {% else %}
                            {{ 'order.shipping_unfulfilled' | t }}
                          {% endif %}
                        {% endset %}
                        <div class="{{ status_classes }}">
                          <svg class="{{ status_icon_classes }}"><use xlink:href="#truck"/></svg> {{ 'order.shipping' | t }}: <strong class="account-order-status-value">{{ shipping_status_label }}</strong>
                        </div>
                        <div class="account-order-total">
                          {{ 'general.total' | t }} {{ order.total | money }}
                        </div>
                        <a class="account-order-detail-link btn-link" href="{{ store.customer_order_url(order) }}">{{ 'account.view_detail' | t }}</a>
                      </div>

                      <div class="order-item-image-container">
                        {% for item in order.items %}
                          {% if loop.first %} 
                            {% if loop.length > 1 %} 
                              <span class="card-img-pill">{{ loop.length }} {{ 'account.products' | t }}</span>
                            {% endif %}
                            {{ item.featured_image | product_image_url("") | img_tag(item.featured_image.alt, {class: 'order-item-image'}) }}
                          {% endif %}
                        {% endfor %}
                      </div>
                    </div>
                  {% endblock %}
                  {% block card_foot %}
                    {% if add_checkout_link %}
                      <a class="btn btn-primary btn-medium" href="{{ order.checkout_url | add_param('ref', 'orders_list') }}" target="_blank" rel="noopener noreferrer">{{ 'order.make_payment' | t }}</a>
                    {% elseif order.order_status_url != null %}
                      <a class="btn btn-primary btn-medium" href="{{ order.order_status_url | add_param('ref', 'orders_list') }}" target="_blank" rel="noopener noreferrer">{{ 'account.track_order' | t }}</a>
                    {% endif %}
                    {% include 'snippets/modals/cancel-order-modal.tpl' with { redirect_to: store.customer_order_url(order), cancellation_type: order.cancellation_type } %}
                  {% endblock %}
                {% endembed %}

                {{ component('nubesdk-slot', { type: "after_account_order_item", pick: order.id }) }}

              </div>
            {% endfor %}
          </div>
        {% else %}
          <div class="account-orders-empty">
            <svg class="account-orders-empty-icon icon-inline"><use xlink:href="#cart"/></svg>
            <p class="account-orders-empty-text">{{ 'account.first_purchase' | t }}</p>
            {{ 'account.go_to_store' | t | a_tag(store.url, '', 'account-orders-empty-cta btn btn-primary') }}
          </div>
        {% endif %}
      </div>
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.account_orders",
  "class": "section section-main-account-orders",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.account_orders"}],
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
    "page_templates": ["account/orders"]
  }
}
{% endschema %}
