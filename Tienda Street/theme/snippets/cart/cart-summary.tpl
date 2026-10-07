{% if not cart_page %}

	{# Gift progress bar #}
	{% include "snippets/promotions/gift-promotion-progress.tpl" with {container_class: 'cart-summary-gift-promotion-bar'} %}

	{# Free shipping progress bar #}
	<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>
		{% include "snippets/shipping/shipping-free-rest.tpl" with {bar_classes: 'cart-summary-free-shipping-bar'} %}
	</div>

	{# Cart shipping and pickup #}

	{{ component('nubesdk-slot', { type: "before_cart_shipping_options" }) }}

	{% include "snippets/cart/cart-fulfillment.tpl" %}

	{{ component('nubesdk-slot', { type: "after_cart_shipping_options" }) }}

{% endif %}

{# Coupon input #}

{% if settings.cart_coupon %}
	<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>
		{% include "snippets/promotions/coupon-input.tpl" %}
	</div>
{% endif %}

{% if cart_page %}

	<div id="cart-sticky-summary" class="position-sticky-md cart-page-totals">

		{# Gift progress bar #}
		{% include "snippets/promotions/gift-promotion-progress.tpl" with {container_class: 'cart-page-gift-promotion-bar d-none d-md-block'} %}

		{# Free shipping progress bar #}
		<div class="d-none d-md-block">
			<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>
				{% include "snippets/shipping/shipping-free-rest.tpl" with {bar_classes: 'cart-page-free-shipping-bar'} %}
			</div>
		</div>

{% endif %}

		{# Cart totals #}

		{% include "snippets/cart/cart-totals.tpl" %}

		{# Cart main CTA #}

		{% set cart_page_value = cart_page ? true : false %}

		{% include "snippets/cart/cart-button.tpl" with {cart_page: cart_page_value} %}

{% if cart_page %}
	{# End of sticky module #}
	</div>
{% endif %}
