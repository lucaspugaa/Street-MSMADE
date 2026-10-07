{# Product Media - Image gallery with thumbnails #}

<div class="js-product-images product-images" {{ block | block_attributes }} data-store="product-image-{{ product.id }}">
	{% include 'snippets/product/product-image.tpl' with { block_settings: block.settings } %}
</div>

{% schema %}
{
	"name": "t:names.multimedia",
	"icon": "PictureIcon",
	"limit": 1,
	"settings": [
		{
			"type": "header",
			"content": "t:names.gallery"
		},
		{
			"type": "setting",
			"setting_type": "radio",
			"id": "format",
			"label": "t:settings.format_desktop",
			"options": [
				{ "value": "grid", "label": "t:options.grid" },
				{ "value": "slider", "label": "t:options.slider" }
			],
			"default": "slider"
		},
		{
			"type": "setting",
			"setting_type": "select",
			"id": "columns",
			"label": "t:settings.columns_desktop",
			"icon": "DesktopIcon",
			"options": [
				{ "value": "1", "label": "t:options.columns_1" },
				{ "value": "2", "label": "t:options.columns_2" },
				{ "value": "1_and_2", "label": "t:options.columns_1_and_2" }
			],
			"default": "1",
			"visible_if": "{{ block.settings.format == 'grid' }}"
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
			"default": 16,
			"icon": "MarginIcon",
			"visible_if": "{{ block.settings.format == 'grid' }}"
		},
		{
			"type": "setting",
			"setting_type": "toggle",
			"id": "show_thumbnails",
			"label": "t:names.thumbnails",
			"header_toggle": true,
			"default": true
		},
		{
			"type": "setting",
			"setting_type": "radio",
			"id": "thumbnail_position",
			"label": "t:settings.thumbnail_position_desktop",
			"options": [
				{ "value": "left", "label": "t:options.left" },
				{ "value": "bottom", "label": "t:options.bottom" }
			],
			"default": "left",
			"visible_if": "{{ block.settings.show_thumbnails and block.settings.format == 'slider' }}"
		},
		{
			"type": "paragraph",
			"content": "t:settings.mobile_only",
			"visible_if": "{{ block.settings.show_thumbnails and block.settings.format == 'grid' }}"
		}
	]
}
{% endschema %}
