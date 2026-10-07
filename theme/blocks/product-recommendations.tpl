{# Product Recommendations Block #}
{% set columns = block.settings.columns | default('4') %}
{% set columns_mobile = block.settings.columns_mobile | default('2') %}

<div
	class="products-list-slider"
	{{ block | block_attributes }}
	data-columns-desktop="{{ columns }}"
	data-columns-mobile="{{ columns_mobile }}"
	data-store="product-recommendations-{{ block.id }}"
>
	{% include 'snippets/product-list/products-section.tpl' with {
		id: section_id,
		data_component: data_component,
		products_amount: section_products | length,
		products_array: section_products,
		product_template_path: 'snippets/product-list/product-item/item.tpl',
		product_template_params: {'slide_item': true},
		slider_controls_position: 'bottom',
		slider_pagination: true,
		section_classes: {
			section: js_class ~ ' position-relative',
			container: 'position-relative',
			slider_container: swiper_class ~ ' js-recommendations-swiper swiper-container',
			slider_wrapper: 'swiper-wrapper swiper-products-slider ' ~ (columns_mobile == '1' ? 'grid-1'),
			slider_control_pagination: swiper_class ~ '-pagination swiper-pagination swiper-pagination-bullets swiper-pagination-outside w-100',
			slider_control_prev_container: swiper_class ~ '-prev swiper-button-prev swiper-button-outside',
			slider_control_next_container: swiper_class ~ '-next swiper-button-next swiper-button-outside',
		},
	} %}
</div>

{% schema %}
{
	"name": "t:names.products",
	"icon": "ListIcon",
	"limit": 1,
	"deletable": false,
	"settings": [
		{
			"type": "header",
			"content": "t:names.disposition"
		},
		{
			"type": "setting",
			"setting_type": "select",
			"id": "columns",
			"label": "t:settings.columns_desktop",
			"icon": "DesktopIcon",
			"options": [
				{ "value": "3", "label": "t:options.columns_3" },
				{ "value": "4", "label": "t:options.columns_4" },
				{ "value": "5", "label": "t:options.columns_5" },
				{ "value": "6", "label": "t:options.columns_6" }
			],
			"default": "4"
		},
		{
			"type": "setting",
			"setting_type": "select",
			"id": "columns_mobile",
			"label": "t:settings.columns_mobile",
			"icon": "MobileIcon",
			"options": [
				{ "value": "1", "label": "t:options.columns_1" },
				{ "value": "2", "label": "t:options.columns_2" }
			],
			"default": "2"
		}
	]
}
{% endschema %}
