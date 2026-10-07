{# Product Description Section #}

{% set show_title = section.settings.show_title %}
{% set show_social = section.settings.show_social %}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}

{% if product.description is not empty %}


	<div
		{% if full_width %}class="section-full-width"{% endif %}
		data-section-id="{{ section.id }}"
		data-store="product-description-{{ product.id }}"
		{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
			
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
		{% if page_width %}
			</div>
		{% endif %}
	</div>


{% endif %}

{% schema %}
{
	"name": "t:names.product_description",
	"icon": "AlignLeftIcon",
	"class": "section section-product-description section-margin",
	"deletable": false,
	"limit": 1,
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
		},
		{
			"type": "header",
			"content": "t:names.colors"
		},
		{
			"type": "setting",
			"setting_type": "color",
			"id": "background_color",
			"label": "t:settings.background",
			"default": "transparent"
		},
		{
			"type": "setting",
			"setting_type": "color",
			"id": "text_color",
			"label": "t:settings.text",
			"default_setting": "text_color"
		},
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
			"default": 32,
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
			"default": 0,
			"icon": "horizontal_padding",
			"disabled_if": "{{ section.settings.section_width == 'page' }}"
		}
	],
	"enabled_on": {
		"page_templates": ["product"]
	},
	"presets": [
		{
			"name": "t:names.product_description",
			"category": "t:categories.products",
			"settings": {
				"show_title": true,
				"show_social": true,
				"section_width": "page",
				"vertical_padding": 32,
				"horizontal_padding": 0
			}
		}
	]
}
{% endschema %}
