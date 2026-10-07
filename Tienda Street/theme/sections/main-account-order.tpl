{#
  Account Order Section
  Single order detail view with status, items, and shipping info.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="account-order-section"
  data-store="{{ is_subscription ? 'account-subscription-detail-' ~ subscription.id : 'account-order-detail-' ~ order.id }}"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    {% if is_subscription %}
      {% include 'snippets/subscriptions/subscription-detail.tpl' %}
    {% else %}

      {{ component('nubesdk-slot', { type: "before_account_order_detail" }) }}

    {% if cancel_error == 'in_review' %}
      <div class="alert alert-info">
        <p class="font-weight-bold">{{ 'order.cancel_review_title' | t }}</p>
        {% if store.cancel_review_time %}
          <p>{{ ('order.cancel_review_body_' ~ store.cancel_review_time_unit) | t | replace('{1}', store.cancel_review_time) | replace('{2}', customer.email) }}</p>
        {% else %}
          <p>{{ 'order.cancel_review_email' | t | replace('{1}', customer.email) }}</p>
        {% endif %}
      </div>
    {% elseif cancel_success and order.status != 'cancelled' %}
      <div class="alert alert-info">
        <p class="font-weight-bold">{{ 'order.cancel_review_title' | t }}</p>
        <p>{{ 'order.cancel_fallback_body' | t | replace('{1}', customer.email) }}</p>
      </div>
    {% endif %}
    <div class="account-page-content">
      <div class="order-detail-info">
        {% if log_entry %}
          <h4>{{ 'order.shipping_status' | t }}:</h4>{{ log_entry }}
        {% endif %}
        <div class="order-detail-line">
          <svg class="order-detail-icon icon-inline"><use xlink:href="#calendar"/></svg> {{ 'order.date' | t }}: <strong>{{ order.date | i18n_date('%d/%m/%Y') }}</strong> 
        </div>
        <div class="order-detail-line">
          <svg class="order-detail-icon icon-inline"><use xlink:href="#info"/></svg> {{ 'order.status' | t }}: <strong>{{ order.status == 'open' ? 'order.status_open' | t : (order.status == 'closed' ? 'order.status_closed' | t : (order.status == 'cancellation_pending' ? 'order.status_cancellation_pending' | t : 'order.status_cancelled' | t)) }}</strong>
        </div>
        <div class="order-detail-line-compact">
          <svg class="order-detail-icon icon-inline"><use xlink:href="#credit-card"/></svg> {{ 'order.payment' | t }}: <strong>{% if order.payment_status == 'pending' %}{{ 'order.payment_pending' | t }}{% elseif order.payment_status == 'authorized' %}{{ 'order.payment_authorized' | t }}{% elseif order.payment_status == 'paid' %}{{ 'order.payment_paid' | t }}{% elseif order.payment_status == 'voided' %}{{ 'order.payment_voided' | t }}{% elseif order.payment_status == 'refunded' %}{{ 'order.payment_refunded' | t }}{% else %}{{ 'order.payment_abandoned' | t }}{% endif %}</strong>
        </div>
        <div class="order-detail-line">
          <svg class="order-detail-icon icon-inline"><use xlink:href="#wallet"/></svg> {{ 'order.payment_method' | t }}: <strong>{{ order.payment_name }}</strong>
        </div>

        {% if order.address %}
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
          <div class="order-detail-line">
            <svg class="order-detail-icon icon-inline"><use xlink:href="#truck"/></svg> {{ 'order.shipping' | t }}: <strong>{{ shipping_status_label }}</strong>
          </div>
          <div class="order-detail-line"> 
            <svg class="order-detail-icon icon-inline"><use xlink:href="#location"/></svg> <strong>{{ 'order.shipping_address' | t }}:</strong>
            <span class="order-detail-address">
              {{ order.address | format_address }}
            </span>
          </div>
        {% endif %}
        {% if order_subscription %}
          {% include 'snippets/subscriptions/subscription-summary.tpl' with { order_subscription: order_subscription } %}
        {% endif %}
        {% include 'snippets/modals/cancel-order-modal.tpl' with { order: order, cancellation_type: order.cancellation_type } %}
      </div>
      <div class="order-detail-items-container">

        {{ component('nubesdk-slot', { type: "before_account_order_items" }) }}

        <div class="order-items-header bottom-line d-none d-md-grid">
          <div>{{ 'order.product' | t }}</div>
          <div class="order-items-header-center">{{ 'general.price' | t }}</div>
          <div class="order-items-header-center">{{ 'general.quantity' | t }}</div>
          <div class="order-items-header-total">{{ 'general.total' | t }}</div>
        </div>
        <div class="order-detail">
          {% for item in order.items %}
            <div class="order-item">
              <div class="order-item-main">
                <div class="order-item-image-container">
                  {{ item.featured_image | product_image_url("small") | img_tag(item.featured_image.alt, {class: 'd-block order-item-image'}) }} 
                </div>
                <div class="order-item-name">
                  {{ item.name }} <span class="order-items-header-center d-inline-block d-md-none">x{{ item.quantity }}</span>
                </div>
              </div>
              <div class="order-items-header-center d-none d-md-block">
                {{ item.unit_price | money }}
              </div>
              <div class="order-items-header-center d-none d-md-block">
                {{ item.quantity }}
              </div>
              <div class="order-items-header-total">
                {{ item.subtotal | money }}
              </div>
            </div>
          {% endfor %}
        </div>

        {{ component('nubesdk-slot', { type: "after_account_order_items" }) }}

        {% set totals_text_classes = 'order-totals-line' %}
        <div class="order-totals-container">
          {% if order.show_shipping_price %}
            <div class="{{ totals_text_classes }}">
              <span>{{ 'order.shipping_cost' | t | replace('{1}', order.shipping_name) }}:</span>
              <span>
                {% if order.shipping == 0 %}
                  {{ 'shipping.free' | t }}
                {% else %}
                  {{ order.shipping | money_long }}
                {% endif %}
              </span>
            </div>
          {% else %}
            <div class="{{ totals_text_classes }}">
              <span>{{ 'order.shipping_cost' | t | replace('{1}', order.shipping_name) }}:</span>
              <span>{{ 'shipping.to_agree' | t }}</span>
            </div>
          {% endif %}
          {% if order.discount %}
            <div class="{{ totals_text_classes }}">
              <span>{{ 'order.discount' | t | replace('{1}', order.coupon) }}:</span>
              <span>{{ order.discount | money }}</span>
            </div>
          {% endif %}
          {% if order.shipping or order.discount %}
            <div class="{{ totals_text_classes }}">
              <span>{{ 'general.subtotal' | t }}:</span>
              <span>{{ order.subtotal | money }}</span>
            </div>
          {% endif %}
          <div class="order-total">
            <span>{{ 'general.total' | t }}:</span> 
            <span>{{ order.total | money }}</span>
          </div>
          {% if order.pending %}
            <a class="btn btn-primary btn-big w-100" href="{{ order.checkout_url | add_param('ref', 'orders_details') }}" target="_blank">{{ 'order.make_payment' | t }}</a>
          {% endif %}
        </div>
      </div>
    </div>

      {{ component('nubesdk-slot', { type: "after_account_order_detail" }) }}

    {% endif %}
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.account_order",
  "class": "section section-main-account-order",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.account_order"}],
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
    "page_templates": ["account/order"]
  }
}
{% endschema %}
