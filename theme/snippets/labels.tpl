{#
  Labels
  Product labels: discount percentage, out of stock, promotions and free shipping.
#}

{# Visibility #}

{% set group = group ?? true %}
{% set has_not_any_label = not (offer_only or promotion_only or free_shipping_only or no_stock_only) %}

{# Out of stock labels visibility #}

{% set show_out_of_stock_label = not (product.has_stock and product.variations) or product.variations %}

{# Free shipping labels visibility #}

{% set shipping_best_discount = cart.free_shipping.min_price_free_shipping %}
{% set product_price_above_free_shipping_minimum = shipping_best_discount and (product.price >= shipping_best_discount.min_price_raw) %}
{% set free_shipping_combines_with_discounts = shipping_best_discount.combines_with_other_discounts %}
{% set can_show_config_free_shipping = free_shipping_combines_with_discounts or not product.promotional_price_percentage %}
{% set show_free_shipping_label = product.free_shipping or (product_price_above_free_shipping_minimum and can_show_config_free_shipping) %}
{# Promotions labels visibility #}

{% set product_has_promotions = product.has_stock and product.hasVisiblePromotionLabel %}

{# Discount labels visibility #}

{% set show_discount_labels = 
	product.has_stock
	and not (prioritize_promotion_over_offer and product_has_promotions) 
%}

{% set promotion_nxm_long_wording = promotion_nxm_long_wording ?? true %}
{% set offer_percentage_wording = offer_percentage_wording ?? true %}

{% set group_data_store = group_data_store ?? true %}

{% if group %}
	<div class="labels {{ labels_classes.group }}" {% if group_data_store %}data-store="product-item-labels"{% endif %}>
{% endif %}

		{# Out of stock label #}

		{% if show_out_of_stock_label 
			and (has_not_any_label or no_stock_only or free_shipping_and_no_stock_only) 
			and not promotion_and_offer_only
			and not without_no_stock
		%}
			{% set stock_label_text = no_stock_custom_wording ?? ('general.no_stock' | t) %}
			<div class="js-stock-label-private label {{ labels_classes.no_stock }}" data-store="product-item-label-stock" {% if defer_stock_label_text %}data-label="{{ stock_label_text }}"{% endif %} {% if product.has_stock %}style="display:none;"{% endif %}>
				{% if defer_stock_label_text and product.has_stock %}
					{# Text deferred: JS will inject it from data-label on variant change #}
				{% else %}
					{{ stock_label_text }}
				{% endif %}
			</div>
		{% endif %}

		{# Discount label #}
		
		{% if show_discount_labels
			and (has_not_any_label or offer_only or promotion_and_offer_only)
			and not free_shipping_and_no_stock_only
			and not without_offer
		%}
			<div class="js-offer-label-private label {{ labels_classes.offer }}" data-store="product-item-offer-label" data-promotion-type="price-discounts" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% endif %}>
				{% set custom_label = product.getPriceDiscountCustomLabel %}
				{% set has_custom_promotion_label = custom_label and custom_label | trim %}

				{% if has_custom_promotion_label %}
					{{ custom_label }}
				{% else %}

					{% if offer_custom_wording %}
						{{ offer_custom_wording }}
					{% else %}

						<span class="label-offer-percentage {{ labels_classes.offer_percentage }}">
							{% if offer_negative_discount_percentage %}-{% endif %}<span class="js-offer-percentage">{{ product.promotional_price_percentage |round }}</span>%
						</span>
						{% if offer_percentage_wording %}
							<span class="label-offer-percentage-text {{ labels_classes.offer_percentage_text }}"> {{ 'payments.off_label' | t }}</span>
						{% endif %}
					{% endif %}
				{% endif %}
			</div>
		{% endif %}

		{# Promotion label #}

		{% if product_has_promotions 
			and (has_not_any_label or promotion_only or promotion_and_offer_only)
			and not free_shipping_and_no_stock_only
			and not without_promotion
		%}
			<div class="js-promotion-label-private label {{ labels_classes.promotion }}" data-store="product-item-promotion-label" data-promotion-type="quantity-discounts">
				{% include 'snippets/promotions/promotion-label-text.tpl' with {
					nxm_long_wording: promotion_nxm_long_wording,
					quantity_long_wording: promotion_quantity_long_wording,
				} %}
			</div>
		{% endif %}

		{# Free shipping label #}

		{% if (has_not_any_label or free_shipping_only or free_shipping_and_no_stock_only) 
			and not promotion_and_offer_only 
			and not product.is_non_shippable
		%}
			<div class="js-shipping-label-private {% if not product.free_shipping %}js-free-shipping-minimum-label{% endif %} label {{ labels_classes.shipping }}" data-store="product-item-label-shipping" data-promotion-type="free-shipping" {% if not show_free_shipping_label %} style="display: none;"{% endif %}>
				<svg class="label-icon icon-inline {{ labels_classes.shipping_icon }}"><use xlink:href="#truck"/></svg>
				{% if shipping_icon %}
					<span class="label-shipping-text {{ labels_classes.shipping_text }}">
				{% endif %}
					{% if shipping_custom_wording %}
						{{ shipping_custom_wording }}
					{% elseif product.free_shipping or shipping_best_discount.is_free %}
						{% if free_shipping_short_wording %}
							{{ 'shipping.free' | t }}
						{% else %}
							{{ 'product.free_shipping' | t }}
						{% endif %}
					{% elseif shipping_best_discount.discount_type == 'percentage' %}
						{{ shipping_best_discount.discount_value | round }}% {{ 'shipping.discount' | t }}
					{% elseif shipping_best_discount.discount_value_money %}
						{{ shipping_best_discount.discount_value_money }} {{ 'shipping.discount' | t }}
					{% endif %}
				{% if shipping_icon %}
					</span>
				{% endif %}
			</div>
		{% endif %}

		{# Custom content #}

		{% if labels_custom_content %}
			{{ labels_custom_content | raw }}
		{% endif %}

{% if group %}
	</div>
{% endif %}
<span class="hidden" data-store="stock-product-{{ product.id }}-{% if product.has_stock %}{% if product.stock %}{{ product.stock }}{% else %}infinite{% endif %}{% else %}0{% endif %}"></span>
<span class="js-free-shipping-combines-config hidden" data-combines="{{ free_shipping_combines_with_discounts ? 'true' : 'false' }}"></span>
