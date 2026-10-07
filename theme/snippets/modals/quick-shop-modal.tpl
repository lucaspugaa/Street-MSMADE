{# Quick shop modal - Uses platform LS.fillQuickshop function #}
{% if settings.quick_shop %}
	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'quickshop-modal',
		data_component: 'quickshop-modal',
		position: {
			appear_from: 'bottom',
		},
		layout: {
			width_desktop: 'large',
		},
		modal_classes: {
			header: 'modal-header-close-only',
			close_icon: 'icon-inline',
		},
	} %}
		{% block modal_body %}
			<div class="js-quickshop-spinner quickshop-spinner" style="display: none;">
				<svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
			</div>
			<div class="js-product-item-private js-item-product js-product-container js-quickshop-container" data-product-id="" data-variants="" data-quickshop-id="">
				<div class="grid grid-md-2">
					<div class="quickshop-image-container">
					<div class="js-quickshop-image-padding">
						{% include 'snippets/image.tpl' with {
							image_classes: 'js-product-item-image-private js-quickshop-img quickshop-image img-fluid w-100',
							image_lazy_js: true,
							image_thumbs: false,
						} %}
					</div>
					</div>
					<div class="js-item-variants quickshop-details">
						<div class="js-item-name quickshop-name" data-store="product-item-title-{{ product.id }}"></div>
						<div class="quickshop-price-container price-container" data-store="product-item-price-{{ product.id }}">
							<span class="js-compare-price-display price-compare"></span>
						<div class="quickshop-price-row">
							<span class="js-price-display quickshop-price font-family-body"></span>
						</div>
							{% include 'snippets/payments/payment-discount-price.tpl' with {
									visibility_condition: settings.payment_discount_price,
									location: 'product',
									container_classes: "quickshop-discount-container",
									text_classes: {
										price: 'quickshop-discount-price font-family-body'
									}
								} %}
						</div>
						<div id="quickshop-form" class="quickshop-form quickshop-form-container"></div>
					</div>
				</div>
			</div>
		{% endblock %}
	{% endembed %}
{% endif %}
