{#
  Shipping Free Rest
  Free shipping progress bar and messages for cart and product page.
#}
{% if product_detail %}

	{% if not product.free_shipping %}
		{# Wording to notice that adding one more product free shipping is achieved #}

		<div class="js-shipping-add-product-label shipping-add-product-label" style="display: none;">
			<span class='js-fs-add-this-product'>{{ 'shipping.add_product_free' | t }}</span>
			<span class='js-fs-add-one-more' style='display: none;'>{{ 'shipping.add_one_more_free' | t }}</span>
			<strong class='shipping-free-highlight'>{{ 'shipping.get_free_shipping' | t }}</strong>
		</div>
	{% endif %}

{% else %}

	<div class="js-fulfillment-info js-allows-non-shippable" {% if not cart.has_shippable_products %}style="display: none"{% endif %}>

		{# Free shipping progress bar — always rendered, hidden until available #}
		{% set shipping_best_discount = cart.free_shipping.min_price_free_shipping %}
		{% set has_free_shipping_bar_available = shipping_best_discount.min_price_raw > 0 or cart.free_shipping.cart_has_free_shipping %}

		{# Partial shipping discount reward phrase — mirrors product-form.tpl's shipping_discount_label #}
		{% set is_partial_shipping_discount = shipping_best_discount.discount_type and not shipping_best_discount.is_free %}
		{% set shipping_reward_label = (('product.free_shipping' | t) | lower) %}
		{% if is_partial_shipping_discount %}
			{% if shipping_best_discount.discount_type == 'percentage' %}
				{% set shipping_reward_label = (shipping_best_discount.discount_value | round) ~ '% ' ~ ('shipping.discount' | t) %}
			{% else %}
				{% set shipping_reward_label = shipping_best_discount.discount_value_money ~ ' ' ~ ('shipping.discount' | t) %}
			{% endif %}
		{% endif %}

		{% embed "snippets/progress-bar.tpl" with {
			container_class: 'js-ship-free-rest ' ~ bar_classes ~ ' shipping-progress-bar box',
			visibility_condition: has_free_shipping_bar_available,
			icon_name: 'truck',
			title_class: 'js-ship-free-rest-message ship-free-rest-message',
		} %}
			{% block title_content %}
				<div class="ship-free-rest-text bar-progress-success">
					{% if is_partial_shipping_discount %}
						{{ 'shipping.great_shipping_discount' | t(shipping_reward_label) }}
					{% else %}
						{{ 'shipping.great_free_shipping' | t }}
					{% endif %}
				</div>
				<div class="ship-free-rest-text bar-progress-amount">
					{{ 'shipping.almost_free_shipping' | t('<span class="js-ship-free-dif"></span>', shipping_reward_label) | raw }}
				</div>
				<div class="ship-free-rest-text bar-progress-condition">
					{% if is_partial_shipping_discount %}
						<span class="text-accent">{{ shipping_reward_label }}</span>
					{% else %}
						{{ 'shipping.free' | t }}
					{% endif %}
					{{ 'shipping.free_shipping_exceeding' | t }} <span class="js-ship-free-min-price">{{ shipping_best_discount.min_price }}</span>
				</div>
			{% endblock %}
		{% endembed %}
	</div>
{% endif %}
