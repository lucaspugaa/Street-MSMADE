{#
  Cart Panel
  Cart items list and empty state for the AJAX cart modal.
#}

{{ component('nubesdk-slot', { type: "before_line_items" }) }}

<div class="js-ajax-cart-list">
	{# Cart panel items #}
	{% if cart.items %}
		{% for item in cart.items %}
			{% include "snippets/cart/_cart-item.tpl" %}
		{% endfor %}
	{% endif %}
</div>

{{ component('nubesdk-slot', { type: "after_line_items" }) }}

<div class="js-empty-ajax-cart" {% if cart.items_count > 0 %}style="display:none;"{% endif %}>
	{# Cart panel empty #}
	<div class="alert alert-info" data-component="cart.empty-message">{{ 'cart.empty' | t }} </div>
</div>
<div id="error-ajax-stock" style="display: none;">
	<div class="alert alert-warning m-3">
		{{ 'cart.out_of_stock_message' | t }}<a href="{{ store.products_url }}" class="cart-stock-link btn-link">{{ 'cart.see_others' | t }}</a>
	</div>
</div>

<div class="cart-row">
	{% include "snippets/cart/cart-summary.tpl" %}
</div>
