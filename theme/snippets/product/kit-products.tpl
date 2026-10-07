{% set location = location | default('product') %}
{% set is_cart = location == 'cart' %}
{% set kit_lines = is_cart ? kit_components : (product.is_kit ? product.kit_components() : []) %}
{% set data_component = is_cart ? 'cart.kit-breakdown' : 'kit-breakdown' %}

{% if kit_lines | length > 0 %}
	<div {% if not is_cart %}class="product-kit"{% endif %} data-store="{{ is_cart ? 'cart-kit-components' : 'product-kit-components' }}" data-component="{{ data_component }}">
		<ul class="product-kit-list" data-component="{{ data_component }}.list">
			{% for line in kit_lines %}
				{% set line_name = is_cart ? line.short_name : line.name %}
				{% set line_variant = is_cart ? line.short_variant_name : line.variation_name %}
				{% set line_image = is_cart ? line.featured_image : line.image %}
				{% set show_quantity = is_cart or line.quantity > 1 %}
				{% set show_link = not is_cart and line.is_visible %}
				{% set has_variations = not is_cart and (line.variations | length > 0) %}
				<li data-component="{{ data_component }}.item">
					{% if show_link %}
						<a href="{{ line.url }}">
					{% endif %}
							<div class="product-kit-item">
								<div class="product-kit-image-wrap">
									{% include 'snippets/image.tpl' with {
										image_src: line_image,
										product_image: true,
										image_alt: (is_cart ? line_name : line_image.alt) | escape,
										image_classes: 'product-kit-image',
										image_thumbs: ['tiny', 'thumb', 'small'],
									} %}
								</div>
								<div class="product-kit-name">
									<span data-component="{{ data_component }}.item-name">
										{{ line_name }} {% if line_variant and not has_variations %}{{ line_variant }}{% endif %}
									</span>
									{% if show_quantity %}
										<span class="product-kit-quantity" data-component="{{ data_component }}.item-quantity"> x {{ line.quantity }}</span>
									{% endif %}
								</div>
							</div>
					{% if show_link %}
						</a>
					{% endif %}
					{% if has_variations %}
						{% include 'snippets/product/kit-product-variants.tpl' %}
					{% endif %}
				</li>
			{% endfor %}
		</ul>
	</div>
{% endif %}
