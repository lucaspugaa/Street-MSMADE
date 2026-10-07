{#
  Product Form
  Main product detail form: breadcrumbs, images, variants, add-to-cart and related blocks.
#}
{% set show_sku = settings.product_sku %}
{% set show_stock = settings.product_stock %}
{% set show_savings = settings.compare_price_saved_money %}
{% set show_payment_discount = settings.payment_discount_price %}
{% set show_installments = settings.product_detail_installments %}
{% set show_bullet_variants = settings.variant_format == 'buttons' %}
{% set show_color_images = settings.image_color_variants %}
{% set size_guide = settings.size_guide_url %}
{% set show_last_product = settings.last_product %}
{% set last_product_limit = settings.latest_products_available %}
{% set last_product_message = settings.last_product_text %}
{% set stock_color_override = settings.stock_foreground_color %}
{% set show_shipping = settings.shipping_calculator_product_page %}
{% set show_sold_count = settings.products_sold %}
{% set sold_count_threshold = settings.quantity_products_sold %}

<div class="product-content">

	{# Breadcrumbs for product page #}

	{% if not home_main_product %}
		{% include 'snippets/breadcrumbs.tpl' %}
	{% endif %}

	{# Sold products quantity #}

	{% set products_sold_limit = sold_count_threshold ? sold_count_threshold : 0 %}
	{% if show_sold_count and (product.sold_qty > products_sold_limit) %}
		<div class="product-sold-count">
			{% if product.sold_qty > 10 %}
				+{{ (product.sold_qty/ 10)|round(0, 'floor') * 10 }}
			{% else %}
				{{ product.sold_qty }}
			{% endif %}
			{{ 'product.sold' | t }}
		</div>
	{% endif %}

	{# Product name #}

	{% if home_main_product %}
		<h2 class="js-product-name product-name">{{ product.name }}</h2>
	{% else %}

		{# Product SKU #}

		{% if show_sku and product.sku %}
			<div class="product-sku">
				{{ 'product.sku' | t }}: <span class="js-product-sku">{{ product.sku }}</span>
			</div>
		{% endif %}

		{{ component('nubesdk-slot', { type: "before_product_detail_name" }) }}

		<h1 class="js-product-name product-name" data-store="product-name-{{ product.id }}">{{ product.name }}</h1>

		{{ component('nubesdk-slot', { type: "after_product_detail_name" }) }}
		
	{% endif %}

	{# Product price #}

	{% set is_subscription_only_product = product.isSubscribable() and product.isSubscriptionOnly() %}

	{{ component('nubesdk-slot', { type: "before_product_detail_price" }) }}

	{% if product.compare_at_price > product.price %}
		{% set discount_rate_percentage = ((product.compare_at_price) - (product.price)) * 100 / (product.compare_at_price) %}
	{% endif %}
	{% if not is_subscription_only_product %}
		<div class="js-price-container product-price" data-store="product-price-{{ product.id }}">
			<div class="product-price-main">
				<div id="compare_price_display" class="js-compare-price-display product-price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %} style="display:block;"{% endif %}>
					{% if product.compare_at_price and product.display_price %}
						{{ product.compare_at_price | money }}
					{% endif %}
				</div>
				<div class="product-price-row">
					<span class="js-price-display product-price-display" id="price_display" {% if not product.display_price %}style="display:none;"{% endif %} data-product-price="{{ product.price }}">
						{% if product.display_price %}
							{{ product.price | money }}
						{% endif %}
					</span>
					<span class="js-offer-label product-offer-label" {% if not product.compare_at_price %}style="display:none;"{% endif %}>
						<span class="js-offer-percentage">{{ discount_rate_percentage | round }}</span>% {{ 'payments.off_label' | t }}
					</span>
					{{ component('promotional-price-details', {
						promotional_price_details_classes: {
							container: 'product-price-promo-container',
							trigger: 'product-price-promo-trigger',
							icon: 'product-price-promo-icon icon-inline',
							detail_container: 'product-price-promo-card',
							detail_row: 'product-price-promo-detail-row',
							detail_total: 'product-price-promo-detail-total'
						},
						promotional_price_details_icon_svg_id: 'promotions',
					}) }}
				</div>
			</div>
			{% set show_compare_price_saved_amount = not (show_payment_discount and product.maxPaymentDiscount.value > 0) and show_savings %}

			{% include 'snippets/promotions/compare-price-saved-amount.tpl' with {
					visibility_condition: show_compare_price_saved_amount,
					discount_percentage: false,
				} %}

			{% include 'snippets/promotions/price-discount-disclaimer.tpl' with {
				show_compare_price_saved_amount: show_compare_price_saved_amount,
			} %}

			{% include 'snippets/product/price-without-taxes.tpl' with {
					container_classes: "product-price-without-taxes",
				}
			%}

			{% include 'snippets/payments/payment-discount-price.tpl' with {
					visibility_condition: show_payment_discount,
					location: 'product',
					container_classes: "product-payment-discount-price",
					text_classes: {
						price: 'h5 font-family-body'
					}
				} %}
		</div>
	{% endif %}

	{% include 'snippets/subscriptions/subscription-price.tpl' with {
		location: is_subscription_only_product ? 'product_detail',
		subscription_classes: {
			container: 'product-subscription-price',
			prices_container: 'product-subscription-prices',
			price_compare: 'product-subscription-compare',
			price_with_subscription: 'product-subscription-main-price',
			discount: 'product-subscription-discount',
			price_without_taxes_container: 'product-subscription-taxes',
		},
		subscription_discount_position: 'inline',
	} %}

	{{ component('nubesdk-slot', { type: "after_product_detail_price" }) }}

	{% set installments_info = product.installments_info_from_any_variant %}
	{% set hasDiscount = product.maxPaymentDiscount.value > 0 %}
	{% set show_payments_info = show_installments and product.show_installments and product.display_price and installments_info %}

	{{ component('nubesdk-slot', { type: "before_product_detail_payment_options" }) }}

	{% if not home_main_product and (show_payments_info or hasDiscount) %}
		<div {% if installments_info %}data-target="#installments-modal"{% endif %} class="{% if installments_info %}js-modal-open-private js-fullscreen-modal-open{% endif %} js-product-payments-container product-payments-info" {% if not product.display_price or not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
	{% endif %}
		{% if show_payments_info %}
			{% include 'snippets/payments/installments.tpl' with {location: 'product_detail', container_classes: { installment: "product-installment"}} %}
		{% endif %}

		{% set hideDiscountContainer = not (hasDiscount and product.showMaxPaymentDiscount) %}
		{% set hideDiscountDisclaimer = not product.showMaxPaymentDiscountNotCombinableDisclaimer %}

		<div class="js-product-discount-container product-payment-discount" {% if hideDiscountContainer %}style="display: none;"{% endif %}>
			<span class="text-accent">{{ product.maxPaymentDiscount.value }}% {{ 'product.discount_off' | t }}</span> {{ 'product.paying_with' | t }} {{ product.maxPaymentDiscount.paymentProviderName }}
			{% set max_installments = product.maxPaymentDiscount.maxInstallments %}
			<span
				class="js-payment-discount-installments"
				data-text-singular="{{ 'product.in_installments_singular' | t('{1}') }}"
				data-text-plural="{{ 'product.in_installments_plural' | t('{1}') }}"
				{% if not max_installments %}style="display: none;"{% endif %}
			>{{ (max_installments == 1 ? 'product.in_installments_singular' : 'product.in_installments_plural') | t(max_installments) }}</span>
			<div class="js-product-discount-disclaimer product-payment-discount-disclaimer" {% if hideDiscountDisclaimer %}style="display: none;"{% endif %}>
                {{ product.showMaxPaymentDiscountCombinesWithSomeDiscounts
                    ? 'product.not_combinable_some' | t
                    : 'product.not_combinable' | t }}
			</div>
		</div>
	{% if not home_main_product and (show_payments_info or hasDiscount) %}
			<a id="btn-installments" class="product-payments-link btn-link" href="#" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
				{% if not hasDiscount and not show_installments %}
					{{ 'product.see_payment_methods' | t }}
				{% else %}
					{{ 'product.see_more_details' | t }}
				{% endif %}
			</a>
		</div>
	{% endif %}

	{{ component('nubesdk-slot', { type: "after_product_detail_payment_options" }) }}

	{# Product form, includes: Variants, CTA and Shipping calculator #}

	{{ component('nubesdk-slot', { type: "before_product_detail_add_to_cart" }) }}

	<form id="product_form" class="js-product-form product-form" method="post" action="{{ store.cart_url }}" data-store="product-form-{{ product.id }}" data-contact-url="{{ store.contact_url }}">
		<input type="hidden" name="add_to_cart" value="{{product.id}}" />

		{# Product availability #}
		{% set show_product_quantity = product.available and product.display_price %}

		{# Gift promotion message #}
		{% include 'snippets/promotions/gift-promotion-message.tpl' %}

		{# Free shipping minimum message #}
		{% set shipping_best_discount = cart.free_shipping.min_price_free_shipping %}
		{% set has_shipping_best_discount = shipping_best_discount.min_price %}
		{% set has_product_free_shipping = product.free_shipping %}

		{% if not product.is_non_shippable and show_product_quantity %}
			<div class="js-free-shipping-minimum-message free-shipping-message product-free-shipping" {% if not (has_shipping_best_discount or has_product_free_shipping) %}style="display: none;"{% endif %}>
				<div class="product-free-shipping-inner">
					<span class="product-free-shipping-icon">
						<svg class="free-shipping-icon icon-inline"><use xlink:href="#truck"/></svg>
					</span>
					<div class="product-free-shipping-body">
						{% if has_product_free_shipping or shipping_best_discount.is_free or not shipping_best_discount.discount_type %}
							{% set shipping_discount_label = 'product.free_shipping' | t %}
						{% elseif shipping_best_discount.discount_type == 'percentage' %}
							{% set shipping_discount_label = (shipping_best_discount.discount_value | round) ~ '% ' ~ ('shipping.discount' | t) %}
						{% else %}
							{% set shipping_discount_label = shipping_best_discount.discount_value_money ~ ' ' ~ ('shipping.discount' | t) %}
						{% endif %}
						<span class="text-accent">{{ shipping_discount_label }}</span>
						{% set has_min_price_threshold = shipping_best_discount.min_price_raw > 0 %}
						<span {% if not has_product_free_shipping %}class="js-shipping-minimum-label"{% endif %} {% if has_product_free_shipping or cart.free_shipping.cart_has_free_shipping or not has_min_price_threshold %}style="display: none;"{% endif %}>
							{{ 'product.free_shipping_exceeding' | t }} <span class="js-ship-free-min-price">{{ shipping_best_discount.min_price }}</span>
						</span>
						{% if not has_product_free_shipping %}
							<div class="js-free-shipping-discount-not-combinable product-free-shipping-notice">
								{{ 'product.not_combinable' | t }}
							</div>
						{% endif %}
					</div>
				</div>
			</div>
		{% endif %}

		{# Promotion details message #}

		{% set accent_label_classes = 'promotion-detail-title label label-primary' %}

		{% set custom_label = product.getPromotionCustomLabel %}
		{% set has_custom_promotion_label = custom_label and custom_label | trim %}

		{% if has_custom_promotion_label %}
			<div class="{{ accent_label_classes }}">{{ custom_label }}</div>
		{% endif %}

		{% include 'snippets/promotions/promotions-details.tpl' with {
			has_custom_promotion_label: has_custom_promotion_label,
		} %}

		{% if template == "product" %}
			{% set show_size_guide = true %}
		{% endif %}

		{% if product.variations %}
			{% include "snippets/product/product-variants.tpl" with {
				show_size_guide: show_size_guide,
				bullet_variants: show_bullet_variants,
				image_color_variants: show_color_images,
				size_guide_url: size_guide
			} %}
		{% endif %}

		{% include 'snippets/product/kit-products.tpl' %}

		{% if product.is_kit %}
			{# Kit component variants; synced by the kit module and posted on add-to-cart. #}
			<input type="hidden" name="kit_selections" class="js-kit-selections" value="">
		{% endif %}

		{% if show_last_product and show_product_quantity %}
			{% set stock_style = stock_color_override ? '--stock-color: ' ~ stock_color_override ~ ';' : '' %}
			<div class="{% if product.variations or product.is_kit %}js-last-product{% endif %} product-stock-alert text-stock" style="{{ stock_style }}{% if product.selected_or_first_available_variant.stock != 1 %} display: none;{% endif %}">
				{{ last_product_message }}
			</div>
			{% if last_product_limit %}
				{% set latest_products_limit = last_product_limit %}
				<div class="{% if product.variations or product.is_kit %}js-latest-products-available{% endif %} product-stock-alert text-stock" data-limit="{{ latest_products_limit }}" style="{{ stock_style }}{% if product.selected_or_first_available_variant.stock > latest_products_limit or product.selected_or_first_available_variant.stock == null or product.selected_or_first_available_variant.stock == 1 %} display: none;{% endif %}">
					{{ 'product.only_left' | t }} <span class="js-product-stock">{{ product.selected_or_first_available_variant.stock }}</span> {{ 'product.in_stock' | t }}
				</div>
			{% endif %}
		{% endif %}

		<div class="product-actions{% if show_product_quantity and not product.isSubscribable() %} grid grid-auto-1{% endif %}">
			{% set product_quantity_home_product_value = home_main_product ? true : false %}
			{% if show_product_quantity %}
				{% include "snippets/product/product-quantity.tpl" with {home_main_product: product_quantity_home_product_value, product_stock: show_stock} %}
			{% endif %}

			{% include 'snippets/subscriptions/subscription-selector.tpl' with {
				allow_subscription_only: is_subscription_only_product,
			} %}

			{% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
			{% set texts = {'cart': 'product.add_to_cart' | t, 'contact': 'product.contact_for_price' | t, 'nostock': 'product.out_of_stock' | t, 'catalog': 'product.contact_for_price' | t} %}
			{% set kit_buyable_state = product.display_price ? 'cart' : 'contact' %}
			{% set btn_value = is_subscription_only_product ? ('subscriptions.subscribe' | t) : texts[state] %}
			<div class="buy-button-container {% if product.isSubscribable() %}product-subscription-container{% endif %}">

				{# Add to cart CTA #}

				<input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-big btn-block {{ state }}" value="{{ btn_value }}" {% if state == 'nostock' or product.isPlaceholder() %}disabled{% endif %} data-store="product-buy-button" data-component="product.add-to-cart" data-adding-text="{{ 'product.adding' | t }}" data-no-stock-text="{{ 'product.no_more_stock' | t }}" data-no-stock-label="{{ 'general.no_stock' | t }}" data-contact-label="{{ 'general.contact_price' | t }}" data-add-to-cart-label="{{ 'product.add_to_cart' | t }}" {% if product.is_kit and not store.is_catalog %}data-kit-label-buyable="{{ texts[kit_buyable_state] }}" data-kit-class-buyable="{{ kit_buyable_state }}" data-kit-label-nostock="{{ texts.nostock }}"{% endif %} data-editable-ajax-cart="{{ store.editable_ajax_cart_enabled ? 'true' : 'false' }}"/>

				{# Fake add to cart CTA visible during add to cart event #}

				{% include 'snippets/placeholders/button-placeholder.tpl' with {custom_class: "w-100"} %}

			</div>
		</div>
		{% if settings.ajax_cart %}
		<div class="js-added-to-cart-product-message product-added-message" style="display: none;">
			<svg class="product-added-icon icon-inline"><use xlink:href="#check"/></svg>
			<span class="product-added-message-text">
				{{ 'product.already_added' | t }}<a href="#" class="js-modal-open-private product-added-message-link btn-link" data-target="#modal-cart">{{ 'product.view_cart' | t }}</a>
			</span>
		</div>
		{% endif %}

	</form>

	{{ component('nubesdk-slot', { type: "after_product_detail_add_to_cart" }) }}

	{% if not home_main_product %}
		{# Shipping and pickup options - hidden for home_main_product #}

		{% set show_product_fulfillment = show_shipping and (store.has_shipping or store.branches) and not product.free_shipping and not product.is_non_shippable %}

		{{ component('nubesdk-slot', { type: "before_product_detail_shipping_options" }) }}

		{% if show_product_fulfillment and not home_main_product %}
			<div class="product-shipping-wrapper shipping-wrapper">
				{# Shipping calculator and branch link #}

				<div id="product-shipping-container" class="product-shipping-calculator list" {% if not product.display_price or not product.has_stock %}style="display:none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}" data-free-label="{{ 'shipping.free' | t }}">
					{% if store.has_shipping %}
						{% include "snippets/shipping/shipping-calculator.tpl" with {'shipping_calculator_variant' : product.selected_or_first_available_variant, 'product_detail': true} %}
					{% endif %}
				</div>

				{% if store.branches %}
					{# Link for branches #}
					{% include "snippets/shipping/branches.tpl" with {'product_detail': true} %}
				{% endif %}
			</div>

		{% endif %}

		{{ component('nubesdk-slot', { type: "after_product_detail_shipping_options" }) }}

	{% endif %}
</div>

{% if not home_main_product %}
	{# Product payments details #}
	{% include 'snippets/product/product-payment-details.tpl' %}
{% endif %}


