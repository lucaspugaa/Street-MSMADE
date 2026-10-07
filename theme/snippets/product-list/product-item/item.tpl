{#
  Product Item
  Single product card for grids, sliders and cross-selling with image, price and add-to-cart.
#}

{# Global item settings #}

{% set show_installments_settings_value = (settings.product_installments ? true : false) and not reduced_item %}
{% set show_color_variants_settings_value = (settings.product_color_variants ? true : false) and not reduced_item %}
{% set show_quick_shop_settings_value = (settings.quick_shop ? true : false) and not reduced_item and not product.is_kit %}
{% set show_secondary_image_settings_value = settings.product_hover ? true : false %}
{% set labels_value = reduced_item ? false : true %}
{% set price_compare_value = reduced_item ? false : true %}
{% set discount_rate_value = reduced_item ? false : true %}
{% set slide_item = slide_item | default(false) %}
{% set slide_item_class = slide_item ? 'js-item-slide swiper-slide ' %}
{% set reduced_item_classes = reduced_item ? 'product-item-reduced' %}

{# Image slider #}

{% set show_image_slider = 
    (template == 'category' or template == 'search')
    and settings.product_item_slider 
    and not reduced_item
    and not slide_item
    and not has_filters
    and product.other_images
%}

{% set data_expand = show_image_slider ? '50' %}

{# Defaults #}

{% set url_with_selected_variant = has_filters ? ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url %}
{% set labels = labels_value %}
{% set discount_rate = discount_rate_value %}
{% set price_compare = price_compare_value %}
{% set installments_short_wording = installments_short_wording ?? true %}
{% set modal_trigger_data = 'data-target=#quickshop-modal' %}

{# Variants data configuration #}
{% set include_variants_data = false %}
{% set variants_data_value = null %}

{% if show_color_variants_settings_value %}
    {% set include_variants_data = true %}
    {% set variants_data_value = product.variants_object_reduced | json_encode %}
{% elseif show_quick_shop_settings_value and store.has_quick_shop_ajax %}
    {% set include_variants_data = true %}
    {% set variants_data_value = '[]' %}
{% elseif show_quick_shop_settings_value %}
    {% set include_variants_data = true %}
    {% set variants_data_value = product.variants_object_reduced | json_encode %}
{% endif %}

{% set include_quickshop_id = show_color_variants_settings_value or show_quick_shop_settings_value %}

{# Classes #}

{% set labels_group_class = 'product-labels' %}
{% if settings.promotion_labels_position == 'over' and settings.labels_on_image_position == 'bottom' %}
	{% set labels_group_class = labels_group_class ~ ' product-labels-bottom' %}
{% endif %}

{% set label_accent_classes = 'product-item-promo-label label-primary' %}

{% set product_item_classes = {
    item: 'js-product-container js-item-product ' ~ slide_item_class ~ reduced_item_classes,
    information: 'product-item-information-inner',
    price_compare: 'product-item-price-compare',
    subscription_classes: {
        prices_container: 'product-item-subscription-prices',
        price_compare: 'product-item-subscription-compare',
        price_with_subscription: 'product-item-subscription-main-price',
        discount: 'product-item-subscription-discount',
    },
    discount_rate: 'product-item-discount',
    installments: 'product-item-installments',
    labels_group: labels_group_class,
    label_shipping: 'label-secondary shipping-label',
    label_no_stock: 'product-item-no-stock',
} %}

{# Promotional Labels visibility #}

{% set percentage_off_custom_label = product.getPriceDiscountCustomLabel %}
{% set has_custom_percentage_off_promotion_label = percentage_off_custom_label and percentage_off_custom_label | trim %}
{% set promotion_only_value = has_custom_percentage_off_promotion_label ? false : true %}
{% set offer_only_value = has_custom_percentage_off_promotion_label ? true : false %}

<div class="js-product-item-private product-item {{ product_item_classes.item }}" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}"{% if include_variants_data %} data-variants="{{ variants_data_value }}"{% endif %}{% if include_quickshop_id %} data-quickshop-id="quick{{ product.id }}"{% endif %}>

	{% include 'snippets/product-list/product-item/item-image.tpl' with {
		image_data_expand: data_expand,
		secondary_image: show_secondary_image_settings_value,
		slider: show_image_slider,
		slider_pagination_container: true,
		image_priority_high: image_priority_high,
	} %}

	<div class="product-item-information {{ product_item_classes.information }}" data-store="product-item-info-{{ product.id }}">
		<a href="{{ url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="product-item-link {{ product_item_classes.link }}">

			{{ component('nubesdk-slot', { type: "before_product_grid_item_name" }) }}

			<div class="js-item-name product-item-name" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>

			{{ component('nubesdk-slot', { type: "after_product_grid_item_name" }) }}

			{{ component('nubesdk-slot', { type: "before_product_grid_item_price" }) }}

			{% if product.display_price %}
				{% if not product.is_placeholder and product.isSubscribable() and product.isSubscriptionOnly() %}
					{% include 'snippets/subscriptions/subscription-price.tpl' with {
						location: 'product_list',
						subscription_classes: product_item_classes.subscription_classes,
					} %}
				{% else %}
					<div class="product-item-price-container {{ product_item_classes.price_container }}" data-store="product-item-price-{{ product.id }}">
						<span class="js-price-display product-item-price">
							{{ product.price | money }}
						</span>
						{% if price_compare %}
							<span class="js-compare-price-display product-item-price-compare {{ product_item_classes.price_compare }}" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% endif %}>
								{{ product.compare_at_price | money }}
							</span>
						{% endif %}
						{% if discount_rate %}
							<span class="{{ product_item_classes.discount_rate }}" {% if not product.compare_at_price %}style="display:none;"{% endif %}>
								<span class="js-offer-percentage">{{ product.promotional_price_percentage | round }}</span>% {{ 'payments.off_label' | t }}
							</span>
						{% endif %}
					</div>
					{% if show_installments_settings_value %}
						{% include 'snippets/payments/installments.tpl' with {
								location: 'product_item', 
								short_wording: installments_short_wording, 
								container_classes: { 
									installment: product_item_classes.installments
								}
							} %}
					{% endif %}
				{% endif %}
			{% endif %}

			{{ component('nubesdk-slot', { type: "after_product_grid_item_price" }) }}

			{% if not reduced_item %}
				{% if settings.promotion_labels_position == 'below' %}
					{% include 'snippets/labels.tpl' with {
						promotion_only: promotion_only_value,
						offer_only: offer_only_value,
						group_data_store: false,
						labels_classes: {
							group: 'order-first',
							promotion: label_accent_classes,
							offer: label_accent_classes,
						},
					} %}
				{% endif %}

				{% include 'snippets/payments/payment-discount-price.tpl' with {
					visibility_condition: settings.payment_discount_price,
					location: 'product',
					container_classes: 'product-item-payment-discount',
				} %}
				
				{% include 'snippets/subscriptions/subscription-message.tpl' with {
					subscription_icon: true,
				} %}
				{% set product_available_with_price = product.available and product.display_price %}

				{% if not product.is_placeholder and settings.last_product_category and product_available_with_price %}
					<div class="{% if product.variations %}js-last-product{% endif %} product-item-stock-notice"{% if product.selected_or_first_available_variant.stock != 1 %} style="display: none;"{% endif %}>
						{{ settings.last_product_text }}
					</div>
					{% if settings.latest_products_available %}
						{% set latest_products_limit = settings.latest_products_available %}
						<div class="{% if product.variations %}js-latest-products-available{% endif %} product-item-stock-notice" data-limit="{{ latest_products_limit }}" {% if product.selected_or_first_available_variant.stock > latest_products_limit or product.selected_or_first_available_variant.stock == null or product.selected_or_first_available_variant.stock == 1 %} style="display: none;"{% endif %}>
							{{ 'general.only_left' | t }} <span class="js-product-stock">{{ product.selected_or_first_available_variant.stock }}</span> {{ 'general.in_stock' | t }}
						</div>
					{% endif %}
				{% endif %}
			{% endif %}

			{# Variation bullets colors #}
			{% include 'snippets/product-list/product-item/item-colors.tpl' with {
				color_variants: show_color_variants_settings_value,
			} %}
		</a>
		{% if
			not product.is_placeholder
			and ((settings.quick_shop and not product.isSubscribable()) or settings.product_color_variants)
			and product.available
			and product.display_price
			and product.variations
		%}
			<div class="js-item-variants hidden">
				<form class="js-product-form" method="post" action="{{ store.cart_url }}">
					<input type="hidden" name="add_to_cart" value="{{product.id}}" />
					{% if product.variations %}
						{% include "snippets/product/product-variants.tpl" with {quickshop: true} %}
					{% endif %}
					{% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
					{% set texts = {'cart': 'product.add_to_cart', 'contact': 'product.contact_for_price', 'nostock': 'product.out_of_stock', 'catalog': 'product.contact_for_price'} %}

					{% set show_product_quantity = product.available and product.display_price %}

					{{ component('nubesdk-slot', { type: "before_quick_buy_add_to_cart" }) }}

					<div class="quickshop-actions {% if show_product_quantity %}grid grid-auto-1{% endif %}">
						{% if show_product_quantity %}
							{% include "snippets/product/product-quantity.tpl" with {quickshop: true} %}
						{% endif %}
						<div class="buy-button-container">
							<input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary w-100 {{ state }}" value="{{ texts[state] | t }}" {% if state == 'nostock' %}disabled{% endif %} data-adding-text="{{ 'general.adding' | t }}" data-no-stock-text="{{ 'general.no_more_stock' | t }}" data-no-stock-label="{{ 'general.no_stock' | t }}" data-contact-label="{{ 'general.contact_price' | t }}" data-add-to-cart-label="{{ 'product.add_to_cart' | t }}" data-editable-ajax-cart="{{ store.editable_ajax_cart_enabled ? 'true' : 'false' }}"/>
							{% include 'snippets/placeholders/button-placeholder.tpl' with {custom_class: 'w-100'} %}
						</div>
					</div>
				</form>
			</div>
		{% endif %}
		{# Quick shop #}
		{% if not product.is_placeholder %}
			{% include 'snippets/product-list/product-item/item-quick-shop.tpl' with {
				quick_shop: show_quick_shop_settings_value,
			} %}
		{% endif %}
	</div>

	{% if not product.is_placeholder %}
		<span class="hidden" data-store="stock-product-{{ product.id }}-{% if product.has_stock %}{% if product.stock %}{{ product.stock }}{% else %}infinite{% endif %}{% else %}0{% endif %}"></span>
		{% include 'snippets/structured-data/structured-data.tpl' with {'item': true} %}
	{% endif %}
</div>
