{% set is_visible = visibility_condition is not defined or visibility_condition %}

{% if is_visible %}
	{% set is_product = location == 'product' %}
	{% set is_cart = location == 'cart' %}

	{% set max_discount = is_product ? product.maxPaymentDiscount : cart.maxPaymentDiscount %}
	{% set price_value = max_discount.price %}
	{% set combines_with_free_shipping = max_discount.combinesWithFreeShipping ? 'true' : 'false' %}

	{% set hide_on_product = is_product and (not product.display_price or not product.showMaxPaymentDiscount) %}
	{% set hide_on_cart = is_cart and (price_value <= 0 or price_value >= cart.total) %}

	{% set container_default_classes = is_product ? 'js-payment-discount-price-product-container payment-discount-price-product-container ' : 'js-payment-discount-price-cart-container payment-discount-price-cart-container ' %}
	{% set container_classes = container_default_classes ~ container_classes %}
	{% set price_classes = is_product ? 'js-payment-discount-price-product payment-discount-price-product' : 'js-payment-discount-price-cart payment-discount-price-cart' %}

	<div class="{{ container_classes }}" {% if hide_on_product or hide_on_cart %}style="display: none;"{% endif %}>
		{% if is_cart %}
			<span>{{ 'payment_discount.or' | t }}</span>
		{% endif %}
		<span
			class="{{ price_classes }} {{ text_classes.price }}"
			data-priceraw-without-shipping="{{ price_value }}"
			data-combines-with-free-shipping="{{ combines_with_free_shipping }}"
		>
			{{ price_value | money }}
		</span>
		<span>{{ 'payment_discount.with' | t }}</span>
		<span class="{% if is_cart %}js-payment-discount-name-cart{% else %}js-payment-discount-name-product{% endif %} {{ text_classes.payment_method }}">{{ max_discount.paymentProviderName }}</span>
		{% set max_installments = max_discount.maxInstallments %}
		<span
			class="js-payment-discount-installments"
			data-text-singular="{{ 'product.in_installments_singular' | t('{1}') }}"
			data-text-plural="{{ 'product.in_installments_plural' | t('{1}') }}"
			{% if not max_installments %}style="display: none;"{% endif %}
		>{{ (max_installments == 1 ? 'product.in_installments_singular' : 'product.in_installments_plural') | t(max_installments) }}</span>
	</div>
{% endif %}
