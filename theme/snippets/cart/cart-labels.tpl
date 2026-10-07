{#
  Cart Labels
  Promotion and free shipping labels for cart items.
#}

{# Wordings #}

{% set promotions_wording = include('snippets/cart/cart-item-promotion-label-text.tpl') | trim %}

{% set free_shipping_wording = free_shipping_short_wording ? 'shipping.free' | t : 'product.free_shipping' | t %}

{# Labels visibility conditions #}

{% set show_free_shipping = not item.product.is_non_shippable and item.product.free_shipping and not (cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price) %}

{% set accent_label_class = 'label label-primary cart-item-promo-label cart-item-small-label' %}

{% if group %}
    <div class="cart-item-labels" data-store="cart-item-labels">
{% endif %}
    {% if show_free_shipping %}
        <div class="text-accent cart-item-label" data-component="line-item.shipping-label" data-store="cart-item-shipping-label">
            {% if shipping_icon %}
                <svg class="cart-shipping-icon icon-inline"><use xlink:href="#truck"/></svg>
                <span class="">
            {% endif %}
                    {{ free_shipping_wording }}
            {% if shipping_icon %}
                </span>
            {% endif %}
        </div>
    {% endif %}

    {% if is_gift %}
        <div class="{{ accent_label_class }}">
            {{ 'cart.gift_label' | t }}
        </div>
    {% else %}
        <div class="js-cart-item-promotion-label {{ accent_label_class }}"
             data-component="line-item.promotion-label"
             data-store="cart-item-promotion-label"
             {# The !important is needed because we can receive a class like d-inline-block so we need to have more
             priority, and we can't know every class send for the display attribute, so we need this #}
             {% if not promotions_wording %}style="display: none !important;"{% endif %}>
            {{ promotions_wording }}
        </div>
    {% endif %}

    {% if item.is_subscription_item and item.subscription_frequency_value %}
        <div class="cart-item-subscription-frequency" data-component="line-item.subscription-frequency">
            {{ 'our_components.subscriptions.cart_frequency' | tt({'frequency': item.subscription_frequency_value}) }}
        </div>
    {% endif %}
{% if group %}
    </div>
{% endif %}
