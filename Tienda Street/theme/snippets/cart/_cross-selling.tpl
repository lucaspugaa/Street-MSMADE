{#
  Cross Selling
  Promotion form for cross-selling products with variant selection and add-to-cart.
#}
{% if promotion %}
	{% set image = promotion.featuredProductImage %}
	{% set quantity = 1 %}
	{% set not_available_text = 'product.no_stock' | t %}

	<div
		class="js-product-container js-cross-selling-container m-auto"
		data-promotion-id="{{ promotion.id }}"
		data-discount-percentage="{{ promotion.discountPercentage }}"
		data-product-id="{{ promotion.productId }}"
		data-variants="{{ promotion.productVariants }}"
		data-quantity="{{ quantity }}"
		data-add-to-cart-translation="{{ 'product.add_to_cart' | t }}"
		data-not-available-translation="{{ not_available_text }}">
		<div class="position-relative">
			<div class="label label-primary cross-selling-label position-absolute label-top-left">
				{% if promotion.customLabel %}
					{{ promotion.customLabel }}
				{% else %}
					{{ promotion.discountPercentage }}% OFF
				{% endif %}
			</div>

			{% include 'snippets/image.tpl' with {
				image_src: image,
				image_alt: image.alt,
				image_classes: 'js-cross-selling-product-image img-fluid w-100 product-image-limited',
				image_lazy_js: true,
				product_image: true,
			} %}
		</div>

		<div class="px-4 py-3">
			<p class="js-cross-selling-product-name cross-selling-product-name">{{ promotion.productName }}</p>

			<div class="js-cross-selling-prices-container cross-selling-prices price-container">
				<span class="cross-selling-price-item">
					<h5 class="js-cross-selling-original-price cross-selling-original-price price-compare"></h5>
				</span>
				<span class="cross-selling-price-item">
					<h3 class="js-cross-selling-promo-price cross-selling-promo-price"></h3>
				</span>
			</div>

			<form method="post" action="{{ store.cart_url }}">
				<input type="hidden" name="add_to_cart" value="{{ promotion.productId }}">
				<input type="hidden" name="cross_selling_promotion_id" value="{{ promotion.id }}">
				<input type="hidden" name="quantity" value="{{ quantity }}">

				{% for i in 1..3 %}
					{% if promotion.productVariantOptionValues[i] is not empty %}
						<div class="form-group">
							<label class="form-label" for="js-cross-selling-option-value-{{ i }}">
								{{ promotion.productVariantOptionNames[i] }}:
							</label>
							<select class="form-select" name="variation[]" id="js-cross-selling-option-value-{{ i }}">
								{% for optionValue in promotion.productVariantOptionValues[i] %}
									<option value="{{ optionValue }}">{{ optionValue }}</option>
								{% endfor %}
							</select>
							<div class="form-select-icon">
								<svg class="form-select-arrow icon-inline">
									<use xlink:href="#chevron-down"/>
								</svg>
							</div>
						</div>
					{% endif %}
				{% endfor %}

				<div>
					<input
						type="submit"
						class="js-addtocart js-cross-selling-add-to-cart cross-selling-submit btn btn-primary"
						value="{{ not_available_text }}"/>
					{% include 'snippets/placeholders/button-placeholder.tpl' with { custom_class: 'cross-selling-submit' } %}
				</div>
			</form>
		</div>
	</div>
{% endif %}
