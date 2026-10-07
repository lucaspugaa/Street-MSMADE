{# Product Info - Purchase form, description, and nested blocks #}

{% set info_gap = block.settings.gap | default(20) %}
{% set info_vertical_padding = block.settings.vertical_padding | default(0) %}
{% set info_horizontal_padding = block.settings.horizontal_padding | default(0) %}

{% set info_styles %}
	{% if info_gap %}gap: {{ info_gap }}px;{% endif %}
	{% if info_vertical_padding %}padding-top: {{ info_vertical_padding }}px; padding-bottom: {{ info_vertical_padding }}px;{% endif %}
	{% if info_horizontal_padding %}padding-left: {{ info_horizontal_padding }}px; padding-right: {{ info_horizontal_padding }}px;{% endif %}
{% endset %}

<div class="js-product-info product-info d-flex flex-column" {{ block | block_attributes }} data-store="product-info-{{ product.id }}" {% if info_styles | trim %}style="{{ info_styles | trim }}"{% endif %}>
	{# Product form always renders first (implicit, not a tree block) #}
	{% include 'snippets/product/product-form.tpl' %}

	{% for sub_block in block.blocks %}
		{% if sub_block %}
			{% if sub_block.type == 'purchase-info' %}
				{% include 'blocks/purchase-info.tpl' with { block: sub_block } %}
			{% elseif sub_block.type == 'description' %}
				{% include 'blocks/description.tpl' with { block: sub_block } %}
			{% elseif sub_block.type in ['heading', 'text', 'image', 'button', 'group', 'label'] %}
				{% include 'blocks/' ~ sub_block.type ~ '.tpl' with { block: sub_block } %}
			{% endif %}
		{% endif %}
	{% endfor %}
</div>

{% schema %}
{
	"name": "t:names.purchase_info",
	"icon": "InfoCircleIcon",
	"limit": 1,
	"settings": [
		{
			"type": "header",
			"content": "t:names.design"
		},
		{
			"type": "setting",
			"setting_type": "range",
			"id": "gap",
			"label": "t:settings.gap",
			"min": 0,
			"max": 80,
			"step": 4,
			"unit": "px",
			"default": 40,
			"icon": "vertical_spacing"
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
			"default": 8,
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
			"icon": "horizontal_padding"
		}
	],
	"blocks": [
		{ "tags": ["general"] },
		{
			"type": "description",
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
		},
		{
			"type": "purchase-info",
			"name": "t:names.icon_text",
			"icon": "HeartIcon",
			"limit": 2,
			"blocks": [
				{ "type": "icon-text-item", "limit": 6 }
			],
			"presets": [
				{
					"name": "t:names.icon_text",
					"settings": {
						"icon_size": 24,
						"title_size": "paragraph",
						"description_size": "paragraph_small",
						"gap": 24
					},
					"blocks": [
						{
							"type": "icon-text-item",
							"settings": {
								"icon": "returns",
								"title": "t:defaults.main_product.icon_1_title",
								"description": "t:defaults.main_product.icon_1_description"
							}
						},
						{
							"type": "icon-text-item",
							"settings": {
								"icon": "security",
								"title": "t:defaults.main_product.icon_2_title",
								"description": "t:defaults.main_product.icon_2_description"
							}
						}
					]
				}
			],
			"settings": [
				{
					"type": "header",
					"content": "t:names.design"
				},
				{
					"type": "setting",
					"setting_type": "range",
					"id": "icon_size",
					"label": "t:settings.icon_size",
					"min": 16,
					"max": 120,
					"step": 1,
					"unit": "px",
					"default": 24,
					"icon": "horizontal_spacing"
				},
				{
					"type": "setting",
					"setting_type": "select",
					"id": "title_size",
					"label": "t:settings.title_size",
					"options": [
						{ "value": "h1", "label": "t:options.heading_1" },
						{ "value": "h2", "label": "t:options.heading_2" },
						{ "value": "h3", "label": "t:options.heading_3" },
						{ "value": "h4", "label": "t:options.heading_4" },
						{ "value": "h5", "label": "t:options.heading_5" },
						{ "value": "h6", "label": "t:options.heading_6" },
						{ "value": "paragraph", "label": "t:options.paragraph" },
						{ "value": "paragraph_small", "label": "t:options.paragraph_small" }
					],
					"default": "paragraph"
				},
				{
					"type": "setting",
					"setting_type": "select",
					"id": "description_size",
					"label": "t:settings.description_size",
					"options": [
						{ "value": "paragraph_small", "label": "t:options.paragraph_small" },
						{ "value": "paragraph", "label": "t:options.paragraph" },
						{ "value": "paragraph_big", "label": "t:options.paragraph_big" }
					],
					"default": "paragraph_small"
				},
				{
					"type": "setting",
					"setting_type": "range",
					"id": "gap",
					"label": "t:settings.gap",
					"min": 0,
					"max": 50,
					"step": 4,
					"unit": "px",
					"default": 24,
					"icon": "vertical_spacing"
				},
				{
					"type": "header",
					"content": "t:names.colors"
				},
				{
					"type": "setting",
					"setting_type": "color",
					"id": "text_color",
					"label": "t:settings.text",
					"default_setting": "text_color"
				},
				{
					"type": "setting",
					"setting_type": "color",
					"id": "icon_color",
					"label": "t:settings.icon_color",
					"default_setting": "text_color"
				}
			]
		}
	]
}
{% endschema %}
