{#
  Product Item Colors
  Color variant swatches for product grid items.
#}
{% if color_variants and product.variations %}
	<div class="product-item-colors-container order-first">
		{% set own_color_variants = 0 %}
		{% set custom_color_variants = 0 %}

		{% for variation in product.variations %}
			<div class="product-item-colors-variation" data-value="variation_{{ loop.index }}" data-option="{{ loop.index0 }}" >
				{% if variation.name in ['Color', 'Cor'] %}
					{% if variation.options | length > 1 %}
						<div class="product-item-colors">
							{% for option in variation.options | take(3) if option.custom_data %}
								<span title="{{ option.name }}" data-option="{{ option.id }}" data-variation-id="{{ variation.id }}" class="js-product-item-colors-bullet product-item-colors-bullet js-variation-option js-color-variant" style="background: {{ option.custom_data }}"></span>
							{% endfor %}

							{% for option in variation.options %}
								{% if option.custom_data %}
									{% set own_color_variants = own_color_variants + 1 %}
								{% else %}
									{% set custom_color_variants = custom_color_variants + 1 %}
								{% endif %}
							{% endfor %}

							{% set more_color_variants = (own_color_variants - 3) + custom_color_variants %}

							{% if (own_color_variants and custom_color_variants) or (own_color_variants > 3) or custom_color_variants %}
								<span class="product-item-colors-bullet product-item-colors-bullet-text" title="{{ 'product_item.more_colors' | t }}">
									{% if own_color_variants and custom_color_variants %}
										{% if own_color_variants > 3 %}
											+{{ more_color_variants }}
										{% else %}
											+{{ custom_color_variants }}
										{% endif %}
									{% elseif own_color_variants > 3 %}
										+{{ own_color_variants - 3 }}
									{% elseif custom_color_variants %}
										{{ custom_color_variants }} {{ 'product_item.colors' | t }}
									{% endif %}
								</span>
							{% endif %}
						</div>
					{% endif %}
				{% endif %}
			</div>
		{% endfor %}
	</div>
{% endif %}
