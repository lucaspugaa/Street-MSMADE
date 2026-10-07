{% macro radio_content(
	is_subscription,
	price,
	option_name,
	product,
	subscription_options,
	max_discount_option,
	max_subscription_discount,
	combines_with_price_discounts,
	product_has_price_discount
) %}
	<div class="radio-button-text d-grid grid-1-auto">
		<span class="purchase-option-info-container">
			<span class="purchase-option-name">
				{{ option_name | t }}
			</span>
			{% if is_subscription and subscription_options|length > 0 %}

				<span class="js-subscription-main-option-discount-private purchase-option-discount label label-primary label-small" data-subscription-discount="{{ max_subscription_discount }}" {% if not max_subscription_discount %}style="display:none;"{% endif %}>
					{% if combines_with_price_discounts and product_has_price_discount %}+{% endif %}<span class="js-subscription-main-option-discount-value-private purchase-option-discount-value">{{ max_subscription_discount }}</span>{{ 'subscriptions.discount_wording_off' | t }}
				</span>

				{% if subscription_options|length == 1 %}

					<div class="js-subscription-frequencies-private subscription-option-single" style="display:none;">
						{{ ('subscriptions.frequency' | t) | replace('{1}', (subscription_options|first).getFrequencyParam()) }}
					</div>

				{% endif %}
			{% endif %}
		</span>

		<span class="{% if is_subscription %}js-subscription-main-option-price-private{% else %}js-price-display{% endif %} purchase-option-price" data-product-price="{{ price }}">
			{{ price | money }}
		</span>
	</div>

	{% if is_subscription and subscription_options|length > 1 %}

		{% include 'snippets/subscriptions/subscription-options.tpl' with {
			product: product,
			subscription_options: subscription_options,
			max_discount_option: max_discount_option,
			combines_with_price_discounts: combines_with_price_discounts,
			product_has_price_discount: product_has_price_discount,
			product_original_price: product_original_price,
		} %}
	{% endif %}

	{# Hidden inputs with subscription frequency data #}
	<input type="hidden" name="subscription_frequency_option_id" value="{{ max_discount_option.getId() }}" />
	<input type="hidden" name="subscription_frequency_type" value="{{ max_discount_option.getFrequencyType() }}" />
	<input type="hidden" name="subscription_frequency_value" value="{{ max_discount_option.getFrequencyParam() }}" />
	<input type="hidden" name="subscription_frequency_discount" value="{{ max_discount_option.getDiscountPercentage() }}" />
{% endmacro %}

{% if product.isSubscribable() %}
	{# Get subscription data #}
	{% set subscription_data = product.getSubscriptionData() %}
	{% set subscription_options = subscription_data.getSubscriptionsOptions() %}
	{% set max_discount_option = subscription_data.getMaxDiscountSubscriptionOption() %}
	{% set max_subscription_discount = subscription_data.getMaxDiscountAvailableForSubscription() %}
	{% set is_subscription_only = product.isSubscriptionOnly() and allow_subscription_only %}

	{# Subscription price calculation with combined discounts support #}
	{% set product_original_price = product.compare_at_price ? product.compare_at_price : product.price %}
	{% set combines_with_price_discounts = subscription_data.combinesWithPriceDiscounts() %}
	{% set product_has_price_discount = product.compare_at_price and product.compare_at_price > product.price %}

	{% if combines_with_price_discounts and product_has_price_discount %}
		{# CASE: Combined discounts - apply BOTH discounts on the base price #}
		{% set product_discount_percentage = ((product.compare_at_price - product.price) / product.compare_at_price) * 100 %}
		{% set product_discount_amount = product_original_price * (product_discount_percentage / 100) %}
		{% set subscription_discount_amount = max_subscription_discount ? (product_original_price * (max_subscription_discount / 100)) : 0 %}
		{% set subscription_main_price = product_original_price - product_discount_amount - subscription_discount_amount %}
	{% else %}
		{# CASE: Only subscription discount (original behavior) #}
		{% set subscription_main_price = product_original_price * (1 - max_subscription_discount/100) %}
	{% endif %}

	<div class="js-purchase-options-container-private purchase-options-container radio-button-container"
		{% if not product.display_price %}style="display:none;"{% endif %}
		data-component="purchase-options"
		data-subscription-default-frequency-option-id="{{ max_discount_option.getId() }}"
		data-subscription-default-frequency-type="{{ max_discount_option.getFrequencyType() }}"
		data-subscription-default-frequency="{{ max_discount_option.getFrequencyParam() }}"
		data-subscription-default-discount="{{ max_subscription_discount }}"
		data-combines-with-free-shipping="{{ subscription_data.combinesWithFreeShipping() ? 'true' : 'false' }}"
		data-combines-with-price-discounts="{{ subscription_data.combinesWithPriceDiscounts() ? 'true' : 'false' }}"
		data-combines-with-quantity-discounts="{{ subscription_data.combinesWithQuantityDiscounts() ? 'true' : 'false' }}"
		data-combines-with-cart-amount-discounts="{{ subscription_data.combinesWithCartAmountDiscounts() ? 'true' : 'false' }}"
		data-combines-with-app-discounts="{{ subscription_data.combinesWithAppDiscounts() ? 'true' : 'false' }}"
		data-buy-wording="{{ 'product.add_to_cart' | t }}"
		data-buying-wording="{{ is_subscription_only ? ('subscriptions.buying_subscription_onetime' | t) : ('subscriptions.buying_subscription' | t) }}"
		data-payments-wording="{{ 'payments.see_payments' | t }}"
		data-subscription-only="{{ is_subscription_only ? 'true' : 'false' }}"
		data-purchase-type="{{ is_subscription_only ? 'subscription' : 'one-time' }}"
		data-product-stock="{{ product.selected_or_first_available_variant.stock }}"
		data-product-status="{{ store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') }}">

		{# One time purchase option - Only show if product is not subscription only #}
		{% if not is_subscription_only %}
		{% include 'snippets/forms/radio-button.tpl' with {
			id: 'purchase-option-one-time',
			value: 'one-time',
			name: 'purchase_option',
			checked: true,
			label_classes: 'js-purchase-option-item-private',
			input_classes: 'js-purchase-option-private',
			input_data_attributes: {
				'product-price': product.price,
				'component': 'purchase-options-one-time'
			},
			radio_button_custom_content: _self.radio_content(
				false,
				product.price,
				'subscriptions.purchase_type.one_time',
				product,
				subscription_options,
				max_discount_option,
				max_subscription_discount,
				false,
				false
			)
		} %}
		{% endif %}

		{# Subscription purchase option content (shared between both modes) #}
		{% set subscription_option_content %}
			{{ _self.radio_content(
				true,
				subscription_main_price,
				'subscriptions.purchase_type.subscription',
				product,
				subscription_options,
				max_discount_option,
				max_subscription_discount,
				combines_with_price_discounts,
				product_has_price_discount
			) }}
		{% endset %}

		{# Subscription purchase option #}
		{% if is_subscription_only %}
			{# Subscription only: show content without radio button #}
			<div class="js-purchase-option-item-private js-subscription-only-container subscription-only-container" data-component="purchase-options-subscription-only">
				<input type="hidden" name="purchase_option" value="subscription" class="js-purchase-option-private" data-product-price="{{ subscription_main_price }}" data-subscription-discount="{{ max_subscription_discount }}" />
				{{ subscription_option_content }}
			</div>
		{% else %}
			{# Normal products: show radio button #}
			{% include 'snippets/forms/radio-button.tpl' with {
				id: 'purchase-option-subscription',
				value: 'subscription',
				name: 'purchase_option',
				checked: false,
				label_classes: 'js-purchase-option-item-private',
				input_classes: 'js-purchase-option-private',
				input_data_attributes: {
					'product-price': subscription_main_price,
					'subscription-discount': max_subscription_discount,
					'component': 'purchase-options-subscription'
				},
				radio_button_custom_content: subscription_option_content
			} %}
		{% endif %}

		{# Hidden input for cart bypass - starts at 1 for subscription only products #}
		<input type="hidden" name="buy_subscription" value="{{ is_subscription_only ? '1' : '0' }}" />

		{# Cart items warning & shipping options message #}
		{% include 'snippets/subscriptions/subscription-alerts.tpl' %}
	</div>
{% endif %}
