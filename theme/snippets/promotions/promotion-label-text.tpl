{#
  Promotion Label Text
  Promotion label content: custom label, progressive discount or NxM offer text.
#}

{% set custom_label = product.getPromotionCustomLabel %}

{% set has_custom_promotion_label = custom_label and custom_label | trim %}

{% if has_custom_promotion_label %}
	{% set primary_text = custom_label %}
{% else %}
	{% set promotions = product.promotions %}
	{% set featuredPromotion = promotions.getFeaturedPromotion %}

	{% if featuredPromotion.isProgressiveDiscount %}

		{% if promotions.hasMultipleQuantityDiscounts %}

			{% set primary_text = 'promotions.progressive_discount_primary' | t | replace('{1}', featuredPromotion.getDiscountPercentage) %}
			{% set secondary_text = 'promotions.progressive_discount_secondary' | t %}
		{% else %}
			{% set primary_text = featuredPromotion.getDiscountPercentage ~ '% ' ~ (quantity_long_wording ? ('payments.off_label' | t) : '') %}
			{% set secondary_text = 'promotions.quantity' | t | replace('{1}', featuredPromotion.getBuyQuantity) %}
		{% endif %}
	{% else %}

		{% set primary_text = nxm_long_wording ? 'promotions.nxm_long' | t | replace('{1}', featuredPromotion.getBuyQuantity) | replace('{2}', featuredPromotion.getPayQuantity) : 'promotions.nxm' | t | replace('{1}', featuredPromotion.getBuyQuantity) | replace('{2}', featuredPromotion.getPayQuantity) %}
	{% endif %}
{% endif %}

<span>{{ primary_text }}</span>
{% if secondary_text %}
	<span>{{ secondary_text }}</span>
{% endif %}
