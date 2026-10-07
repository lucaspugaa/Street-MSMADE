{#
  Cart Section
  Shopping cart page with product list, quantities, and checkout summary.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
	id="shoppingCartPage"
	data-minimum="{{ settings.cart_minimum_value }}"
	data-store="cart-page"
	style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
	{% if page_width %}
		<div class="container">
	{% endif %}
		<form action="{{ store.cart_url }}" method="post" class="cart-form" data-store="cart-form" data-component="cart">
			{% if error.add %}
				{% include 'snippets/forms/alert.tpl' with {
					type: 'warning',
					message: ('cart.error_messages.' ~ error.add) | t
				} %}
			{% endif %}
			{% for error in error.update %}
				{% if error.error_code == 'out_of_stock' %}
					<div class="alert alert-warning">{{ 'cart.stock_error' | t | replace('{1}', error.requested) | replace('{2}', error.item.name) | replace('{3}', error.stock) }}</div>
				{% else %}
					<div class="alert alert-warning">{{ ('cart.error_messages.' ~ error.error_code) | t }}</div>
				{% endif %}
			{% endfor %}
			{% if cart.items %}
				<div class="cart-page-content">
					<div class="cart-page-products">
						<div class="cart-page-table-header d-none d-md-grid">
							<div>{{ 'cart.products' | t }}</div>
							<div class="cart-page-table-header-totals">
								<div>{{ 'general.quantity' | t }}</div>
								<div>{{ 'general.price' | t }}</div>
								<div>{{ 'general.subtotal' | t }}</div>
							</div>
						</div>

						{{ component('nubesdk-slot', { type: "before_line_items" }) }}

						<div class="js-ajax-cart-list cart-page-items-list">
							{% if cart.items %}
								{% for item in cart.items %}
									{% include "snippets/cart/_cart-item.tpl" with {'cart_page': true} %}
								{% endfor %}
							{% endif %}
						</div>

						{{ component('nubesdk-slot', { type: "after_line_items" }) }}

					</div>
					<div class="cart-page-fulfillment">
						{% include "snippets/promotions/gift-promotion-progress.tpl" with {container_class: 'cart-page-gift-promotion-bar d-md-none'} %}

						{# Free shipping progress bar #}
						<div class="d-md-none">
							<div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>
								{% include "snippets/shipping/shipping-free-rest.tpl" with {bar_classes: 'cart-page-free-shipping-bar'} %}
							</div>
						</div>

						{{ component('nubesdk-slot', { type: "before_cart_shipping_options" }) }}

						{% if settings.shipping_calculator_cart_page %}
							{% include "snippets/cart/cart-fulfillment.tpl" %}
						{% endif %}

						{{ component('nubesdk-slot', { type: "after_cart_shipping_options" }) }}

					</div>
					<div class="cart-page-summary">
						{% include "snippets/cart/cart-summary.tpl" with {cart_page: true} %}
					</div>
				</div>
			{% else %}
				{% if not error %}
					<div class="alert alert-info text-center">{{ 'cart.empty' | t }}</div>
				{% endif %}
			{% endif %}
			<div id="error-ajax-stock" class="cart-stock-alert alert alert-warning" style="display: none;">
				{{ 'cart.out_of_stock_message' | t }}<a href="{{ store.products_url }}" class="cart-stock-link btn-link">{{ 'cart.see_others' | t }}</a>
			</div>
		</form>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.cart_form",
  "class": "section section-main-cart",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.cart_form"}],
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "section_width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "page", "label": "t:options.page" },
        { "value": "full", "label": "t:options.full" }
      ],
      "default": "page"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 0,
      "icon": "vertical_padding"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_padding",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "enabled_on": {
    "page_templates": ["cart"]
  }
}
{% endschema %}
