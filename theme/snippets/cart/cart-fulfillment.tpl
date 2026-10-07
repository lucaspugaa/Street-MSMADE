{# Define conditions to show shipping calculator and store branches on cart #}

{% set show_cart_fulfillment = settings.shipping_calculator_cart_page and (store.has_shipping or store.branches) %}

{% if show_cart_fulfillment %}
  <div class="js-fulfillment-info js-allows-non-shippable cart-fulfillment-info" {% if not cart.has_shippable_products %}style="display: none"{% endif %}>
    <div class="js-visible-on-cart-filled js-has-new-shipping js-shipping-calculator-container">

      {# Saved shipping not available #}

      <div class="js-shipping-method-unavailable shipping-unavailable-alert alert alert-warning" style="display: none;">
        <div>{{ 'cart.shipping_not_available' | t }}</div>
        <div>{{ 'cart.dont_worry' | t }}</div>
      </div>

      {# Shipping calculator and branch link #}

      <div id="cart-shipping-container" class="shipping-wrapper" {% if cart.items_count == 0 %} style="display: none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}" data-free-label="{{ 'shipping.free' | t }}">

        {# Used to save shipping #}

        <span id="cart-selected-shipping-method" data-code="{{ cart.shipping_data.code }}" class="hidden">{{ cart.shipping_data.name }}</span>

        {# Shipping Calculator #}

        {% if store.has_shipping %}
          {% include "snippets/shipping/shipping-calculator.tpl" with { 'product_detail': false} %}
        {% endif %}

        {# Store branches #}

        {% if store.branches %}
          {% include "snippets/shipping/branches.tpl" with {'product_detail': false} %}
        {% endif %}
      </div>
    </div>
  </div>
{% endif %}
