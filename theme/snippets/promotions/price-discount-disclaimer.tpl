{% if product.hasAdvancedPromotionCombinations %}
	{% set promotions = product.promotions %}

	{% if promotions and promotions.hasNonCombinablePriceDiscount %}
		{% set shouldHideInitially = not product.compare_at_price or product.firstVariantHasPromotionalPrice %}
		{% set price_discount_disclaimer_spaced = (show_compare_price_saved_amount ?? false) %}
		<p class="js-price-discount-disclaimer-private price-discount-disclaimer {% if price_discount_disclaimer_spaced %}price-discount-disclaimer-spaced{% endif %}" {% if shouldHideInitially %}style="display:none;"{% endif %}>
			{{ 'promotions.price_discount_not_combinable_with_some' | t }}
		</p>
	{% endif %}
{% endif %}
