{# Prepare custom content for options #}
{% set option_content %}
	{% for option in subscription_options %}
		{% set subscription_option_frequency_text = 'subscriptions.frequency' | t | replace('{1}', option.getFrequencyParam()) %}
		{% set subscription_option_discount = option.getDiscountPercentage() %}

		{# Calculate option price with combined discounts support #}
		{% set base_price = product_original_price ?? (product.compare_at_price ? product.compare_at_price : product.price) %}
		{% if combines_with_price_discounts and product_has_price_discount %}
			{% set product_discount_percentage = ((product.compare_at_price - product.price) / product.compare_at_price) * 100 %}
			{% set product_discount_amount = base_price * (product_discount_percentage / 100) %}
			{% set subscription_discount_amount = subscription_option_discount ? (base_price * (subscription_option_discount / 100)) : 0 %}
			{% set subscription_option_price = base_price - product_discount_amount - subscription_discount_amount %}
		{% else %}
			{% set subscription_option_price = base_price * (1 - subscription_option_discount/100) %}
		{% endif %}

		{% set should_select = option.getId() == max_discount_option.getId() %}

		<div class="js-subscription-option-private js-dropdown-option-private dropdown-custom-option {% if should_select %}frequency-selected selected{% endif %} form-select-option d-grid grid-1-auto"
			data-component="subscription-option"
			data-dropdown-option-text="{{ subscription_option_frequency_text }}"
			data-subscription-option-frequency-id="{{ option.getId() }}"
			data-subscription-option-frequency-type="{{ option.getFrequencyType() }}"
			data-subscription-option-frequency-value="{{ option.getFrequencyParam() }}"
			data-subscription-option-frequency-discount="{{ subscription_option_discount }}" >
			<div class="subscription-option-info">
				<div class="subscription-option-frequency" data-component="subscription-option-frequency">
					{{ subscription_option_frequency_text }}
				</div>
				{% if subscription_option_discount %}
					<div class="subscription-option-discount" data-component="subscription-option-discount">
						{{ 'subscriptions.save' | t | replace('{1}', subscription_option_discount) }}
					</div>
				{% endif %}
			</div>
			<div class="js-subscription-option-price-private subscription-option-price" data-product-price="{{ subscription_option_price }}" data-component="subscription-option-price">
				{{ subscription_option_price | money }}
			</div>
		</div>
	{% endfor %}
{% endset %}

{% include 'snippets/forms/dropdown.tpl' with {
	hidden: true,
	options: subscription_options,
	selected_text: 'subscriptions.frequency' | t | replace('{1}', max_discount_option.getFrequencyParam()),
	dropdown_classes: {
		container: 'js-subscription-frequencies-private subscription-frequencies form-group',
		button: 'js-subscription-dropdown-button-private subscription-dropdown-button form-select',
		options_container: 'js-subscription-dropdown-options-private form-select-options',
		icon: 'form-select-icon icon-inline',
	},
	data_attributes: {
		'component': 'subscription-options',
	},
	option_custom_content: option_content,
} %}
