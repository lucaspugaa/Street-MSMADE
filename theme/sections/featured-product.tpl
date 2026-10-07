{# Featured Product Section - Shows a single product from the featured collection #}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}

{% set products = sections.featured.products %}
{% set has_featured_products = products and products | length > 0 %}

{# Placeholder product: preview without featured products, OR storefront when the store has no products at all #}
{% set show_placeholder = is_preset_preview or (not has_featured_products and (is_preview or not has_products)) %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}

{% if has_featured_products or show_placeholder %}
	{% if has_featured_products and not show_placeholder %}
		{% if section.settings.product_type == 'random' %}
			{% set product = (products | shuffle | first) %}
		{% else %}
			{% set product = products | first %}
		{% endif %}
	{% else %}
		{% set product = create_placeholder_product(
			'product_item.example_name' | t,
			100000,
			('images/placeholders/product/product-1.webp') | static_url
		) %}
	{% endif %}

	<div
		class="js-product-container section-featured-product {% if full_width %}section-full-width{% endif %}"
		id="single-product"
		data-variants="{{ product.variants_object | json_encode }}"
		data-store="home-product-main"
		data-section-id="{{ section.id }}"
		{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
				<div class="product-columns" style="{% if gap %}gap: {{ gap }}px;{% endif %}">
					<div class="js-product-images product-images" data-store="product-image-{{ product.id }}">
						{% include 'snippets/product/product-image.tpl' with { home_main_product: true } %}
					</div>
					<div class="js-product-info product-info" data-store="product-info-{{ product.id }}">
						{% include 'snippets/product/product-form.tpl' with { home_main_product: true } %}
						{% if product.description is not empty %}
							<div class="product-featured-description">
								<div class="js-product-description product-featured-description-text product-description user-content">
									{{ product.description }}
								</div>
								<div class="js-view-description" style="display: none;">
									<button type="button" class="btn-link">
										<span class="js-view-more">{{ 'general.view_more' | t }}</span>
										<span class="js-view-less" style="display: none;">{{ 'general.view_less' | t }}</span>
									</button>
								</div>
							</div>
						{% endif %}
					</div>
				</div>
		{% if page_width %}
			</div>
		{% endif %}
	</div>


{% endif %}

{% schema %}
{
  "name": "t:names.featured_product",
  "icon": "StarIcon",
  "add_section_order": 7,
  "class": "section section-featured-product",
  "limit": 1,
  "settings": [
    {
      "type": "setting",
      "setting_type": "select",
      "id": "product_type",
      "label": "t:settings.product_type",
      "default": "first",
      "options": [
        { "value": "first", "label": "t:settings.product_type_first" },
        { "value": "random", "label": "t:settings.product_type_random" }
      ]
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
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_spacing"
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
      "default": 64,
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
  ],
  "blocks": [],
  "presets": [
    {
      "name": "t:names.featured_product",
      "category": "t:categories.products"
    }
  ]
}
{% endschema %}
