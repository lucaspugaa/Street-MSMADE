{#
	Cart Totals
	Displays cart subtotal, price without taxes, promotions, coupon discount, shipping costs and grand total.
#}

{# IMPORTANT Do not remove this hidden subtotal, it is used by JS to calculate cart total #}
<div class="js-subtotal-price subtotal-price hidden" data-priceraw="{{ cart.total }}" style="display: none;"></div>

{# Used to assign currency to total #}
<div id="store-curr" class="hidden" style="display: none;">{{ cart.currency }}</div>

{% set show_shipping = settings.shipping_calculator_cart_page and (store.has_shipping or store.branches) %}
{% set is_shipping_coupon = cart.coupon_includes_shipping %}

<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>

	<div class="cart-subtotals-container">

		{# Cart subtotal #}

		<div class="cart-totals-row cart-totals-subtotal" data-store="cart-subtotal">
			<span>
				{{ 'general.subtotal' | t }}{% if show_shipping %} {{ 'cart.without_shipping' | t }}{% endif %}:
			</span>
			<span class="js-ajax-cart-total js-cart-subtotal" data-priceraw="{{ cart.subtotal }}" data-component="cart.subtotal" data-component-value='{{ cart.subtotal }}'>{{ cart.subtotal | money }}</span>
		</div>

		{# Cart subtotal without taxes #}

		{% include 'snippets/product/price-without-taxes.tpl' with {
			location: 'cart',
			container_classes: 'cart-totals-row cart-totals-secondary',
		} %}

		{# Cart promotions #}

		<div class="js-total-promotions cart-totals-promotions">
			<span class="js-promo-discount" style="display:none;">{{ 'cart.discount' | t }}</span>
			<span class="js-promo-in" style="display:none;">{{ 'cart.promo_in' | t }}</span>
			<span class="js-promo-all" style="display:none;">{{ 'cart.all_products' | t }}</span>
			<span class="js-promo-buying" style="display:none;"> {{ 'cart.buying' | t }}</span>
			<span class="js-promo-units-or-more" style="display:none;"> {{ 'cart.or_more' | t }}</span>
			<span class="js-cart-discount-automatic" style="display:none;">{{ 'cart.cart_discount_automatic' | t }}</span>
			<span class="js-cart-discount-with-coupon" style="display:none;">{{ 'cart.coupon_discount_label' | t }}</span>
			{% for promotion in cart.promotional_discount.promotions_applied %}
				{% if not promotion.is_subscription_promotion %}
					{% if promotion.scope_value_id %}
						{% set id = promotion.scope_value_id %}
					{% else %}
						{% set id = 'all' %}
					{% endif %}
					<span class="js-total-promotions-detail-row cart-totals-row" id="{{ id }}">
						<span>
							{% if promotion.discount_script_type != "custom" %}
								{% if promotion.discount_script_type == "NAtX%off" %}
									{{ promotion.selected_threshold.discount_decimal_percentage * 100 }}% OFF
								{% elseif promotion.isBuyXPayY %}
									{{ promotion.buy }}x{{ promotion.pay }}
								{% elseif promotion.isCrossSelling %}
									{{ 'cart.discount' | t }}
								{% elseif promotion.isCartDiscount %}
									{% if promotion.coupon_activated %}{{ 'cart.coupon_discount_label' | t }}{% else %}{{ 'cart.cart_discount_automatic' | t }}{% endif %}
									{% if promotion.cart_discount.isPercentage %}{{ promotion.cart_discount.value | round }}%{% else %}{{ promotion.total_discount_amount_short }}{% endif %}
								{% else %}
									{{ promotion.discount_script_type }}
								{% endif %}

								{% if not promotion.isCartDiscount %}
									{{ 'cart.promo_in' | t }} {% if id == 'all' %}{{ 'cart.all_products' | t }}{% else %}{{ promotion.scope_value_name }}{% endif %}
								{% endif %}

								{% if promotion.discount_script_type == "NAtX%off" %}
									<span>{{ 'cart.buying_x_or_more' | t | replace('{1}', promotion.selected_threshold.quantity) }}</span>
								{% endif %}
							{% else %}
								{{ promotion.scope_value_name }}
							{% endif %}
							:
						</span>
						<span>-{{ promotion.total_discount_amount_short }}</span>
					</span>
				{% endif %}
			{% endfor %}
		</div>

		{# Coupon discount inner — reused in both rows below #}

		{% set cart_coupon_discount %}
			<span>{{ 'cart.coupon_discount_label' | t }}</span>
			<span class="js-coupon-discount-amount">{% if cart.coupon_discount_formatted %}-{{ cart.coupon_discount_formatted }}{% endif %}</span>
		{% endset %}

		{# Cart coupon discount — non-shipping coupon: above shipping costs. #}

		<div class="js-coupon-discount-row cart-totals-row cart-totals-promotions" data-coupon-row="non-shipping" {% if not cart.coupon_discount_formatted or is_shipping_coupon %}style="display:none;"{% endif %}>
			{{ cart_coupon_discount }}
		</div>

		{# Cart shipping costs #}

		{% if show_shipping %}
			<div id="shipping-cost-container" class="js-fulfillment-info js-shipping-cost-table cart-totals-row cart-totals-shipping" {% if not cart.has_shippable_products %}style="display:none;"{% endif %}>
				<span>{{ 'cart.shipping_label' | t }}</span>
				<span>
					<span id="shipping-cost" class="cart-totals-hint" data-free-shipping-wording="{{ 'shipping.free' | t }}" data-component="cart.shipping_costs">{{ 'cart.calculate_to_see' | t }}</span>
					<span class="js-calculating-shipping-cost cart-totals-hint" style="display: none">{{ 'cart.calculating' | t }}...</span>
					<span class="js-shipping-cost-empty cart-totals-hint" style="display: none">{{ 'cart.calculate_to_see' | t }}</span>
				</span>
			</div>

			{# Shipping discount row is shown when a partial shipping discount is applied #}
			<div class="js-shipping-discount-row cart-totals-row cart-totals-promotions" data-component="cart.shipping_discount" style="display:none;">
				<span>{{ 'cart.shipping_discount_label' | t }}</span>
				<span class="js-shipping-discount-amount"></span>
			</div>
		{% endif %}

		{# Cart coupon discount — shipping coupon: below shipping costs. #}

		<div class="js-coupon-discount-row cart-totals-row cart-totals-promotions" data-coupon-row="shipping" {% if not cart.coupon_discount_formatted or not is_shipping_coupon %}style="display:none;"{% endif %}>
			{{ cart_coupon_discount }}
		</div>

	</div>

	{{ component('nubesdk-slot', { type: "after_cart_summary" }) }}

	{# Cart total #}

	<div class="js-cart-total-container" data-store="cart-total">

		<div class="cart-totals-row cart-totals-total">
			<span>{{ 'general.total' | t }}:</span>
			<span class="js-cart-total{% if cart.free_shipping.cart_has_free_shipping %} js-free-shipping-achieved{% endif %}{% if cart.shipping_data.selected %} js-cart-saved-shipping{% endif %}" data-component="cart.total" data-component-value='{{ cart.total }}'>{{ cart.total | money }}</span>
		</div>

		{# IMPORTANT Do not remove this hidden total, it is used by JS to calculate cart total #}

		<div class="total-price hidden" style="display: none;">
			{{ 'general.total' | t }}: {{ cart.total | money }}
		</div>

		{# Cart payment discount price #}

		{% include 'snippets/payments/payment-discount-price.tpl' with {
			visibility_condition: settings.payment_discount_price,
			location: 'cart',
			container_classes: 'cart-totals-payment-info',
		} %}

		{# Cart installments #}

		{% if not settings.payment_discount_price %}
			{% include 'snippets/payments/installments.tpl' with {
				location: 'cart',
				container_classes: { installment: 'cart-totals-installments' },
			} %}
		{% endif %}

	</div>

</div>
