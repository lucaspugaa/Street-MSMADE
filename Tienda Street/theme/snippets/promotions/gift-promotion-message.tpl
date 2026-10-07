{% set gift_min_value = store.get_cart_minimum_for_gift() %}

{% if gift_min_value is not null %}
	<div class="gift-promotion-message" data-store="product-gift-promotion">
		<svg class="gift-promotion-icon icon-inline" aria-hidden="true" focusable="false"><use xlink:href="#gift"/></svg>
		<span>
			<span class="gift-promotion-highlight">{{ 'product.gift_promotion.message_highlight' | t }}</span>
			{{ 'product.gift_promotion.message_detail' | t | replace('{1}', gift_min_value | money) }}
		</span>
	</div>
{% endif %}
