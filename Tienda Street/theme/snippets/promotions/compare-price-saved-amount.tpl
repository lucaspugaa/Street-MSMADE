{% set visibility_enabled = visibility_condition is not defined or (visibility_condition is defined and visibility_condition) %}
{% set price_compare_discount = product.compare_at_price > product.price %}
{% set discount_percentage = discount_percentage ?? true %}

{% if visibility_enabled and price_compare_discount %}
	{% set compare_price_difference = product.compare_at_price - product.price %}
	{% set hide_saved_money_message = not (product.compare_at_price or product.display_price) %}

	<span class="js-saved-money-message" {% if hide_saved_money_message %}style="display:none;"{% endif %}>
		<span class="saved-amount-container">
			<span class="saved-amount-text">
				<span>{{ 'product.compare_price_saving_message' | t }}</span>
				<span class="js-offer-saved-money">{{ compare_price_difference | money }}</span>
			</span>
			{% if discount_percentage %}
				<span>
					<span class="js-offer-percentage">{{ product.promotional_price_percentage |round }}</span>%
					{{ discount_percentage_wording ?? '' }}
				</span>
			{% endif %}
		</span>
	</span>
{% endif %}
