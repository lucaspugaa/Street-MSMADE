{#
  Cart Button
  Checkout CTA and minimum purchase alert for cart page and popup.
#}

{{ component('nubesdk-slot', { type: "before_go_to_checkout" }) }}

<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>

  {% set cart_button_classes = 'btn btn-primary btn-big btn-block' %}

  {# Cart page and popup CTA Module #}

  {% set has_validation_messages = cart.checkout_enabled_validation_messages | length > 0 %}
  {% set should_show_checkout_button = cart.checkout_enabled and not has_validation_messages %}

  {% if cart_page %}
  
    {# Cart page CTA and minimum alert: Always render button to ensure it exists in DOM, control visibility via CSS/JS #}

    <input id="go-to-checkout" class="{{ cart_button_classes }}" {{ not should_show_checkout_button ? 'style="display:none"' }} type="submit" name="go_to_checkout" value="{{ 'cart.start_checkout' | t }}"/>

    {# Cart alert messages #}
    {% include 'snippets/forms/checkout-enabled-validation-messages.tpl' with {
        alert_classes: 'alert alert-warning',
        cart_minimum_value: settings.cart_minimum_value
      } %}
  {% else %}

    {# Cart popup CTA and minimum alert #}

    <div class="js-ajax-cart-submit" {{ not should_show_checkout_button ? 'style="display:none"' }} id="ajax-cart-submit-div" >
      <input class="{{ cart_button_classes }}" type="submit" name="go_to_checkout" value="{{ 'cart.start_checkout' | t }}" data-component="cart.checkout-button"/>
    </div>

    {# Cart alert messages #}
    {% include 'snippets/forms/checkout-enabled-validation-messages.tpl' with {
        alert_classes: 'alert alert-warning',
        cart_minimum_value: settings.cart_minimum_value
      } %}

  {% endif %}

  {{ component('nubesdk-slot', { type: "after_go_to_checkout" }) }}

  {# Cart panel continue buying link #}

  <div class="cart-continue-shopping">
    <a href="{% if cart_page %}{{ store.products_url }}{% else %}#{% endif %}" {% if not cart_page %}data-target="#modal-cart"{% endif %} class="{% if not cart_page %}js-modal-close-private{% endif %} btn btn-link">{{ 'cart.view_more_products' | t }}</a>
  </div>
</div>
