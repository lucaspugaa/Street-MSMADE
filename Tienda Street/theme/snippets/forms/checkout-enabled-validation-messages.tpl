{#
  Checkout Enabled Validation Messages
  Displays cart validation messages (e.g. minimum value warning) and checkout-enabled validation messages.
#}
{% set checkout_enabled_validation_messages = cart.checkout_enabled_validation_messages %}
{% set empty_validation_messages = checkout_enabled_validation_messages | length == 0 %}
{% set cart_total = ((cart_minimum_value ?? 0) * 100) %}
{% set min_value = cart_total | money %}

<div id="ajax-cart-minumum-div" class="js-ajax-cart-minimum {{ alert_classes }}" {{ cart.checkout_enabled ? 'style="display:none"' }}>
    {{ 'cart.minimum_value_warning' | t | replace('{1}', min_value) }}
</div>
<input type="hidden" id="ajax-cart-minimum-value" value="{{ cart_total }}"/>

<div class="js-checkout-enabled-validation-messages {{ container_classes }}" data-alert-classes="{{ alert_classes }}" data-component="checkout-enabled-validation-messages" {{ empty_validation_messages ? 'style="display:none"' }} role="status">
    {% for checkout_enabled_validation_message in checkout_enabled_validation_messages %}
        <div class="{{ alert_classes }}" role="alert">{{ checkout_enabled_validation_message }}</div>
    {% endfor %}
</div>
