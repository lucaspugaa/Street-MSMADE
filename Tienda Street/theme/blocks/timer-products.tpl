{# Timer Products Block - Product carousel for timer offers #}

{% set product_list_title = block.settings.title | trim %}

{% set has_block_products = products_array and (products_array | length) > 0 %}
{% if is_preset_preview or (not has_block_products and (is_preview or not has_products)) %}
	{% set products_array = [] %}
	{% for i in 1..8 %}
		{% set placeholder_num = ((i - 1) % 8) + 1 %}
		{% set products_array = products_array | merge([{
			'is_placeholder': true,
			'id': 'placeholder-' ~ i,
			'name': 'product_item.example_name' | t,
			'url': '#',
			'display_price': true,
			'price': 100000,
			'has_stock': true,
			'stock': 1,
			'placeholder_image_url': ('images/placeholders/products/product-' ~ placeholder_num ~ '.webp') | static_url,
			'featured_image': { 'dimensions': { 'width': 440, 'height': 600 }, 'alt': 'product_item.example_name' | t }
		}]) %}
	{% endfor %}
{% endif %}

{% include 'snippets/product-list/products-section.tpl' with {
	title: product_list_title,
	products_array: products_array,
	product_template_path: 'snippets/product-list/product-item/item.tpl',
	product_template_params: {'slide_item': true},
	slider_controls_position: 'with-section-title',
	slider_pagination: true,
	section_classes: {
		section: 'timer-offers-products position-relative',
		container: 'timer-offers-container',
		title: 'timer-offers-title',
		slider_container: 'js-swiper-timer-offers timer-offers-slider swiper-container swiper-container-horizontal',
		slider_wrapper: 'swiper-wrapper swiper-products-slider',
		slider_control_pagination: 'js-swiper-timer-offers-pagination timer-offers-pagination swiper-pagination swiper-pagination-bullets',
		slider_control_prev_container: 'js-swiper-timer-offers-prev position-relative swiper-button-prev slider-arrow-inline',
		slider_control_next_container: 'js-swiper-timer-offers-next position-relative swiper-button-next slider-arrow-inline',
	},
} %}

{% schema %}
{
  "name": "t:names.products",
  "icon": "ListIcon",
  "deletable": false,
  "limit": 1,
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "title",
      "label": "t:settings.title",
      "default": "t:defaults.timer_products"
    },
    {
      "type": "setting",
      "setting_type": "product_list",
      "id": "products_source",
      "label": "t:settings.product_source",
      "default": {"kind": "collection", "id": "timer_offers"}
    }
  ]
}
{% endschema %}
