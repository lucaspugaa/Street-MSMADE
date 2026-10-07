{% if product.showPromotionDetails %}
	{% set promotion_title_classes = (has_custom_promotion_label ?? false) ? 'promotion-detail-title promotion-detail-title-inline' : 'promotion-detail-title label label-primary' %}

	<div class="js-product-promo-container promotion-detail-container" data-store="product-promotion-info" data-promotion-type="quantity-discounts">
		{% set promotions = product.promotions %}

		{# If the product has multiple quantity promotions, we display them in a table. #}

		{% if promotions.hasMultipleQuantityDiscounts %}
			{% include 'snippets/promotions/progressive-discounts-table.tpl' with {
				accordion: progressive_discounts_accordion ?? true,
				promotion_title_classes: promotion_title_classes,
			} %}

		{% else %}
			{# If the product has a single quantity promotion, show its details including scope. #}

			{% set discount = promotions.getQuantityDiscounts[0] %}

			{% if discount.isProgressiveDiscount %}
				<div class="{{ promotion_title_classes }}">
					{{ 'promotions.quantity_discount' | t | replace('{1}', discount.getDiscountPercentage) | replace('{2}', discount.getBuyQuantity) }}
				</div>
			{% else %}
				<div class="{{ promotion_title_classes }}">
					{{ ('promotions.nxm_long' | t | replace('{1}', discount.getBuyQuantity) | replace('{2}', discount.getPayQuantity)) ~ '!' }}
				</div>
			{% endif %}

			{% if discount.hasCategoryScope %}
				<p class="promotion-detail-scope">
					{{ "promotions.valid_for_categories" | t }}:
					{% for name in discount.getScopeValueNames %}
						{{ name }}{{ loop.last ? '.' : ',' }}
					{% endfor %}
				</p>
				<p class="promotion-detail-scope">
					{{ 'promotions.categories_combinable' | t }}
				</p>
			{% elseif discount.hasAllScope %}
				<p class="promotion-detail-scope">
					{{ 'promotions.valid_for_all' | t }}
				</p>
			{% endif %}
		{% endif %}

		{# Indicates if any quantity promotion is not combinable with other promos. #}

		{% if promotions.hasNonCombinableQuantityDiscount %}
			<p class="promotion-detail-disclaimer">
				{% if product.hasAdvancedPromotionCombinations %}
					{% if promotions.hasMultipleQuantityDiscounts %}(*){% endif %}
					{{ 'promotions.not_combinable_with_some' | t }}
				{% else %}
					{{ 'promotions.not_combinable' | t }}
				{% endif %}
			</p>
		{% endif %}
	</div>
{% endif %}
