{# Subscription Message
   Discount badge for subscribable products in product lists. #}

{% if product.isSubscribable() and product.display_price %}
	{# Subscription Discount #}
	{% set subscription_discount = product.getSubscriptionData().getMaxDiscountAvailableForSubscription() %}

	{# Check if it combines with product price discounts #}
	{% set combines_with_price_discounts = product.getSubscriptionData().combinesWithPriceDiscounts() %}
	{% set product_has_price_discount = product.hasPromotionalPrice() %}

	{# Check if product is subscription only #}
	{% set is_subscription_only = product.isSubscriptionOnly() %}
	{% set has_promotional = product.hasPromotionalPrice() %}

	<div class="js-subscription-message-private subscription-message" data-component="subscription-message">
		{% if subscription_icon %}
			<svg class="subscription-message-icon icon-inline"><use xlink:href="#returns-alt"/></svg>
		{% endif %}
		{% if subscription_icon %}
			<span class="subscription-message-text">
		{% endif %}
			{% if subscription_discount %}
				{% if not is_subscription_only %}
					{% set discount_prefix = combines_with_price_discounts and product_has_price_discount ? '+' : ('subscriptions.or' | t | lower) %}
				{% endif %}
				<span class="subscription-message-value" data-component="subscription-message-discount">
					{% if discount_prefix %}{{ discount_prefix }} {% endif %}{{ ('subscriptions.discount' | t) | replace('{1}', subscription_discount) }}
				</span>
				<span class="subscription-message-label" data-component="subscription-message-label">
					{{ 'subscriptions.with_subscription' | t }}
				</span>
			{% else %}
				<span class="subscription-message-label" data-component="subscription-message-label">
					{{ 'subscriptions.available_with_subscription' | t }}
				</span>
			{% endif %}
		{% if subscription_icon %}
			</span>
		{% endif %}
	</div>
{% endif %}
