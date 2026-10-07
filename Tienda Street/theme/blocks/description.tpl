{# Product Description Block #}

{% set show_title = block.settings.show_title %}
{% set show_social = block.settings.show_social %}

{% if product.description is not empty %}
	<div class="product-info-description" {{ block | block_attributes }} data-store="product-description-{{ product.id }}">
		
		{{ component('nubesdk-slot', { type: "before_product_description" }) }}

		{% if show_title %}
			<h3 class="product-description-heading">{{ 'product.description' | t }}</h3>
		{% endif %}
		<div class="js-product-description product-description-content user-content">
			{{ product.description }}
		</div>

		{{ component('nubesdk-slot', { type: "after_product_description" }) }}

		{% if show_social %}
			{% include 'snippets/social/social-share.tpl' %}
		{% endif %}
	</div>
{% endif %}

{% schema %}
{
	"name": "t:names.product_description",
	"icon": "AlignLeftIcon",
	"limit": 1,
	"deletable": false,
	"settings": [
		{
			"type": "setting",
			"setting_type": "toggle",
			"id": "show_title",
			"label": "t:settings.show_title",
			"default": true
		},
		{
			"type": "setting",
			"setting_type": "toggle",
			"id": "show_social",
			"label": "t:settings.show_social",
			"default": true
		}
	]
}
{% endschema %}
