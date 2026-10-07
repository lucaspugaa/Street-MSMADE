{#
  Product Grid
  Loops through products and renders each via product-item.tpl.
#}
{% if products and pages.is_last %}
	<div class="last-page" style="display:none;"></div>
{% endif %}
{% for product in products %}
	{% include 'snippets/product-list/product-item/item.tpl' %}
{% endfor %}
