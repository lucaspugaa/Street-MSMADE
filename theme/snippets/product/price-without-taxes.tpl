{% set location = location | default('product') %}

{% set is_product = location == 'product' %}
{% set is_cart = location == 'cart' %}

{% set store_without_taxes = store.show_prices_without_taxes %}

{# Feature tag to show or not subtotal without taxes  #}
{% set cart_without_taxes = store.hasCartSubtotalWithoutTaxes %}

{% set show_price_without_taxes = is_product ? product.show_price_without_taxes : store_without_taxes and cart_without_taxes %}
{% set price_without_taxes = is_product ? product.price_without_taxes : cart.subtotal_without_taxes %}

{% set hide_on_product = is_product and not product.display_price %}
{% set hide_on_cart = is_cart and price_without_taxes <= 0 %}

{% if show_price_without_taxes %}
	{% set container_default_classes = is_product ? 'js-price-without-taxes-container price-without-taxes-container' : 'js-price-without-taxes-cart-container js-visible-on-cart-filled price-without-taxes-cart-container' %}
	{% set container_classes = container_default_classes ~ ' ' ~ (container_classes | default('')) %}

	{% set price_default_classes = is_product ? 'js-price-without-taxes price-without-taxes' : 'js-price-without-taxes-cart price-without-taxes-cart' %}
	{% set price_classes = price_default_classes ~ ' ' ~ (text_classes.price | default('')) %}

	<div class="{{ container_classes }}" {% if hide_on_product or hide_on_cart %}style="display: none;"{% endif %}>
		<span class="price-without-taxes-label {{ text_classes.label | default('') }}" data-component="price-without-taxes-label">
			{{ 'price_without_taxes' | t }}
			{% if is_cart %}
				:
			{% endif %}
		</span>
		<span class="{{ price_classes }}" data-component="price-without-taxes">{{ price_without_taxes | money }}</span>
	</div>
{% endif %}
