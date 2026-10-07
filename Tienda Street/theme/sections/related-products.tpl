{# Related Products Section #}

{% set products_source = section.settings.products_source %}

{# Design settings #}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}

{# Determine products and section config based on source #}
{% if products_source == 'complementary' %}
    {% set section_products = complementary_product_list %}
    {% set section_id = 'complementary-products-' ~ section.id %}
    {% set data_component = 'complementary-products' %}
    {% set js_class = 'js-product-recommendations' %}
    {% set swiper_class = 'js-swiper-complementary-' ~ section.id %}
{% else %}
    {% set similar_products = [] %}
    {% set data_component = 'related-products' %}
    {% set js_class = 'js-product-recommendations' %}
    {% set swiper_class = 'js-swiper-related-' ~ section.id %}

    {% set alternative_ids = product.metafields.related_products.alternative_product_ids %}
    {% set manual_alternatives = alternative_ids | get_products %}

    {% if manual_alternatives | length > 0 %}
        {% set similar_products = manual_alternatives %}
        {% set data_component = 'alternative-products' %}
        {% set swiper_class = 'js-swiper-alternative-' ~ section.id %}
    {% else %}
        {% set related_products_ids_from_app = product.metafields.related_products.related_products_ids %}
        {% set has_related_from_app = related_products_ids_from_app | get_products | length > 0 %}

        {% if has_related_from_app %}
            {% set similar_products = related_products_ids_from_app | get_products %}
        {% else %}
            {% set max_related_products_length = 8 %}
            {% set max_related_products_achieved = false %}
            {% set related_products_without_stock = [] %}

            {% if related_tag %}
                {% set products_from_category = related_products_from_controller %}
            {% else %}
                {% set products_from_category = product.category.products | shuffle %}
            {% endif %}

            {% for product_from_category in products_from_category if not max_related_products_achieved and product_from_category.id != product.id %}
                {% if product_from_category.stock is null or product_from_category.stock > 0 %}
                    {% set similar_products = similar_products | merge([product_from_category]) %}
                {% elseif (related_products_without_stock | length < max_related_products_length) %}
                    {% set related_products_without_stock = related_products_without_stock | merge([product_from_category]) %}
                {% endif %}
                {% if (similar_products | length == max_related_products_length) %}
                    {% set max_related_products_achieved = true %}
                {% endif %}
            {% endfor %}

            {% if (similar_products | length < max_related_products_length) %}
                {% set number_of_related_products_for_refill = max_related_products_length - (similar_products | length) %}
                {% set related_products_for_refill = related_products_without_stock | take(number_of_related_products_for_refill) %}
                {% set similar_products = similar_products | merge(related_products_for_refill) %}
            {% endif %}
        {% endif %}
    {% endif %}

    {% set section_products = similar_products %}
    {% set section_id = data_component ~ '-' ~ section.id %}
{% endif %}

{% set has_products = section_products | length > 0 %}

{% if has_products %}


	<div
		{% if full_width %}class="section-full-width"{% endif %}
		data-store="{{ data_component }}"
		data-section-id="{{ section.id }}"
		{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
			<div class="d-flex flex-column w-100" style="align-items: flex-start;{% if gap %} gap: {{ gap }}px;{% endif %}">
				{% for block in section.blocks %}
					{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
				{% endfor %}
			</div>
		{% if page_width %}
			</div>
		{% endif %}
	</div>


{% endif %}

{% schema %}
{
    "name": "t:names.related_products",
    "icon": "TagIcon",
    "class": "section-related-products",
    "deletable": false,
    "duplicatable": false,
    "limit": 2,
    "hidden": true,
    "enabled_on": {
        "page_templates": ["product"]
    },
    "blocks": [
        { "tags": ["general"] }
    ],
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
            "id": "gap",
            "label": "t:settings.gap",
            "min": 0,
            "max": 50,
            "step": 4,
            "unit": "px",
            "default": 32,
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
            "default": 32,
            "icon": "horizontal_padding",
            "disabled_if": "{{ section.settings.section_width == 'page' }}"
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
        }
    ]
}
{% endschema %}
