{% set location = location | default('product_detail') %}
{% set is_product_list = location == 'product_list' %}
{% set is_product_detail = location == 'product_detail' %}

{# For product_list, we only show this component for subscription-only products #}
{# For product_detail, we show it for all subscribable products #}
{% set is_subscription_only = product.isSubscribable() ? product.isSubscriptionOnly() : false %}
{% set should_render = (is_product_detail and product.isSubscribable()) or (is_product_list and is_subscription_only and product.display_price) %}

{% if should_render %}
	{% set product_original_price = product.compare_at_price ? product.compare_at_price : product.price %}

	{% set subscription_discount = product.getSubscriptionData().getMaxDiscountAvailableForSubscription() %}

	{# Subscription prices: Uses original price with discount only if there is a subscription discount #}

	{% set subscription_price = product_original_price %}
	{% set subscription_price_without_taxes = product_original_price / (1 + product.tax_percent) %}

	{# Check if it combines with product price discounts - always check these flags #}
	{% set combines_with_price_discounts = product.getSubscriptionData().combinesWithPriceDiscounts() %}
	{% set product_has_price_discount = product.compare_at_price and product.compare_at_price > product.price %}

	{# Calculate combined discount or subscription discount #}
	{# For product_list, we always apply discounts for subscription-only products #}
	{% set has_any_discount = subscription_discount or (combines_with_price_discounts and product_has_price_discount) %}

	{% if has_any_discount %}
		{% if combines_with_price_discounts and product_has_price_discount %}
			{# CASE: Combined discounts - apply BOTH discounts on the base price #}
			{% set product_discount_percentage = ((product.compare_at_price - product.price) / product.compare_at_price) * 100 %}
			{% set product_discount_amount = product_original_price * (product_discount_percentage / 100) %}
			{% set subscription_discount_amount = subscription_discount ? (product_original_price * (subscription_discount / 100)) : 0 %}
			{% set subscription_price = product_original_price - product_discount_amount - subscription_discount_amount %}
		{% elseif subscription_discount %}
			{# CASE: Only subscription discount (original behavior) #}
			{% set subscription_price = subscription_price * (1 - subscription_discount/100) %}
		{% endif %}

		{# Recalculate price without taxes from updated subscription price with discount #}
		{% set subscription_price_without_taxes = subscription_price / (1 + product.tax_percent) %}
	{% endif %}

	{% set subscription_discount_position = subscription_discount_position | default('below') %}

	{# Subscription discount message #}
	{% set subscription_discount_message %}
		<span class="js-subscription-price-discount-private subscription-price-discount {{ subscription_classes.discount }}" {% if not subscription_discount %}style="display:none;"{% endif %} data-component="subscription-price-discount">
			<span class="js-subscription-discount-private subscription-price-discount-value {{ subscription_classes.discount_value }}">
				{# Show + if it combines with product price discounts AND is not subscription only #}
				{% if combines_with_price_discounts and product_has_price_discount and not is_subscription_only %}+{% endif %}<span class="js-subscription-discount-value-private">{{ subscription_discount }}</span>{{ 'subscriptions.discount_wording_off' | t }}
			</span>
			<span class="subscription-price-discount-label {{ subscription_classes.discount_label }}">{{ 'subscriptions.with_subscription' | t }}</span>
		</span>
	{% endset %}

	{# Container visibility: hidden by default for product_detail (shown via JS), visible for product_list and subscription_only #}
	{% set should_hide_initially = is_product_detail and not is_subscription_only %}
	<div class="js-subscription-price-container-private {{ subscription_classes.container }}{% if should_hide_initially %} hidden-important{% endif %}" data-component="subscription-price-container">

		{# Discount message position 'above' - only for product_detail #}
		{% if is_product_detail and subscription_discount_position == 'above' %}
			<div class="subscription-price-discount-container {{ subscription_classes.discount_container }}">
				{{ subscription_discount_message}}
			</div>
		{% endif %}

		<div class="subscription-price-container {{ subscription_classes.prices_container }}">

			{# Original Price - show if there is any discount (subscription or combined product discount) #}

			<span class="js-subscription-price-original-private subscription-price-compare {{ subscription_classes.price_compare }}" {% if not has_any_discount %}style="display:none;"{% endif %} data-component="subscription-price-compare">{{ product_original_price | money }}</span>

			{# Subscription Price - Use h2 for SEO when subscription only in product_detail #}
			{% set use_heading_tag = is_product_detail and is_subscription_only %}
			{% set subscription_price_classes = 'js-subscription-price-private js-price-display subscription-price ' ~ subscription_classes.price_with_subscription %}
			{% set subscription_price_attrs = 'data-product-price="' ~ subscription_price ~ '" data-component="subscription-price"' %}

			{% if use_heading_tag %}
				<h2 class="{{ subscription_price_classes }}" {{ subscription_price_attrs | raw }}>
					{{ subscription_price | money }}
				</h2>
			{% else %}
				<span class="{{ subscription_price_classes }}" {{ subscription_price_attrs | raw }}>
					{{ subscription_price | money }}
				</span>
			{% endif %}
			{# Discount message position 'inline' - only for product_detail #}
			{% if is_product_detail and subscription_discount_position == 'inline' %}
				{{ subscription_discount_message}}
			{% endif %}
		</div>

		{# Discount message position 'below' - only for product_detail #}
		{% if is_product_detail and subscription_discount_position == 'below' %}
			<div class="subscription-price-discount-container {{ subscription_classes.discount_container }}">
				{{ subscription_discount_message}}
			</div>
		{% endif %}

		{# Price without taxes - only for product_detail #}
		{% if is_product_detail %}
			{% include 'snippets/product/price-without-taxes.tpl' with {
					price_without_taxes_custom: subscription_price_without_taxes,
					container_classes: subscription_classes.price_without_taxes_container,
					text_classes: {
						price: "js-subscription-price-without-taxes " ~ subscription_classes.price_without_taxes,
						label: subscription_classes.price_without_taxes_label,
					},
				} %}
		{% endif %}
	</div>
{% endif %}
