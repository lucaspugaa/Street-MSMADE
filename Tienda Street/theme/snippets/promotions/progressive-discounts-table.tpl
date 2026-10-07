{% set max_progresive_discounts_shown = 3 %}
{% set accordion = accordion ?? true %}

<h4 class="{{ promotion_title_classes }}">
	{{ 'promotions.take_more_pay_less' | t }}
</h4>

{% if accordion %}
	<div class="js-accordion-private-container">
{% endif %}
	<table class="promotion-table table">
		{% set promotions = product.promotions %}

		<tbody>
			{% for discount in promotions.getQuantityDiscounts %}

		{% if loop.index0 == max_progresive_discounts_shown and accordion %}
			</tbody>
			<tbody class="js-accordion-private-content table-body-inverted" style="display: none;">
		{% endif %}
				<tr>
					{# Show the discount percentage (or NXM promo format). #}

					<th>
						{% if discount.isProgressiveDiscount %}
							{{ 'promotions.percentage_off' | t | replace('{1}', discount.getDiscountPercentage) }}
						{% else %}
							{{ 'promotions.nxm' | t | replace('{1}', discount.getBuyQuantity) | replace('{2}', discount.getPayQuantity) }}
						{% endif %}
					</th>

					{# Display the minimum purchase units required for the promotion. #}

					<td class="promotion-table-quantity text-lowercase">
						{% if discount.isProgressiveDiscount %}
							{{ 'promotions.quantity_minimum' | t | replace('{1}', discount.getBuyQuantity) }}
						{% else %}
							{{ 'promotions.quantity_exact' | t | replace('{1}', discount.getBuyQuantity) }}
						{% endif %}

						{# Mark with * if the promotion cannot be combined with some promotions. #}

						{% if product.hasAdvancedPromotionCombinations and not discount.combinesWithAll %}
							*
						{% endif %}
					</td>
				</tr>
			{% endfor %}
		</tbody>
	</table>

	{% set totalDiscounts = promotions.getQuantityDiscounts | length %}

	{% if accordion and totalDiscounts > max_progresive_discounts_shown %}
		<div class="js-accordion-private-toggle promotion-table-toggle btn-link btn-link-primary">
			<span class="js-accordion-private-toggle-active">
				{{ 'promotions.see_more_discounts' | t }}
				<svg class="icon-inline"><use xlink:href="#chevron-down"/></svg>
			</span>
			<span class="js-accordion-private-toggle-inactive" style="display: none;">
				{{ 'promotions.see_less_discounts' | t }}
				<svg class="icon-inline"><use xlink:href="#chevron-up"/></svg>
			</span>
		</div>
	{% endif %}
{% if accordion %}
	</div>
{% endif %}
