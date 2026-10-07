{# Product List Section - Featured products with composable blocks #}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set alignment = section.settings.alignment %}
{% set align_items = alignment == 'center' ? 'center' : (alignment == 'right' ? 'flex-end' : 'flex-start') %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}

{# Resolve data-store: first section pointing to a legacy slot claims the legacy name #}
{% set products_block = null %}
{% for block in section.blocks %}
	{% if block.type == 'products' %}
		{% set products_block = block %}
	{% endif %}
{% endfor %}
{% set products_source = products_block ? products_block.settings.products_source : null %}
{% set has_block_products = products_source and products_source.products | length > 0 %}

{# Resolve view-all URL by looking up the selected category id in the global `categories` array. #}
{% set view_all_url = null %}
{% if products_source and products_source.kind == 'category' %}
	{% if products_source.id == '0' %}
		{% set view_all_url = store.products_url %}
	{% else %}
		{% set view_all_url = (categories | flatten_categories_by_id)[products_source.id].url ?? null %}
	{% endif %}
{% endif %}

{% set source_key = products_source and products_source.kind is defined ? products_source.kind ~ ':' ~ products_source.id : '' %}
{% set legacy_data_stores = {
	'collection:primary': 'home-products-featured',
	'collection:new': 'home-products-new',
	'collection:sale': 'home-products-sale'
} %}
{% set legacy_store_name = source_key ? attribute(legacy_data_stores, source_key) : null %}
{% if legacy_store_name and claim_legacy_data_store(legacy_store_name) %}
	{% set data_store_value = legacy_store_name %}
{% else %}
	{% set data_store_value = section.id %}
{% endif %}

{# Section styles #}
{% set section_styles %}
	{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}


{# Hide the section when theres nothing to show. Placeholders kick in for preview or when the store has zero active products at all. #}
{% if has_block_products or is_preview or not has_products %}
	<div
		class="js-products-list-slider section-featured-home {% if full_width %}section-full-width{% endif %}"
		data-store="{{ data_store_value }}"
		data-section-id="{{ section.id }}"
		{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
				{# Pass LCP priority to every block when the section is above the fold; non-visual blocks (heading, text…) ignore it. #}
				{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
				<div class="d-flex flex-column text-{{ alignment }}" style="align-items: {{ align_items }};{% if gap %} gap: {{ gap }}px;{% endif %}">
					{% for block in section.blocks %}
						{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block, is_priority: is_priority_section } %}
					{% endfor %}
				</div>
		{% if page_width %}
			</div>
		{% endif %}
	</div>
{% endif %}


{% schema %}
{
  "name": "t:names.featured_products",
  "icon": "TagIcon",
  "add_section_order": 5,
  "class": "section section-product-list",
  "blocks": [
    { "tags": ["general"] },
    {
      "type": "products",
      "limit": 1
    },
    {
      "type": "view-all-button",
      "limit": 1
    }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "left"
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
  "presets": [
    {
      "name": "t:names.featured_products",
      "category": "t:categories.products",
      "settings": {
        "gap": 32
      },
      "blocks": [
        {
          "type": "group",
          "settings": {
            "direction": "row",
            "alignment": "start",
            "alignment_vertical": "center",
            "width": "fill"
          },
          "blocks": [
            {
              "type": "heading",
              "settings": {
                "title": "t:defaults.product_list",
                "size": "h4"
              }
            },
            {
              "type": "view-all-button",
              "settings": {
                "label": "t:defaults.view_all_button"
              }
            }
          ]
        },
        {
          "type": "products",
          "settings": {
            "products_source": {"kind": "collection", "id": "primary"},
            "format": "grid",
            "columns": "4",
            "columns_mobile": "2"
          }
        }
      ]
    },
    {
      "name": "t:names.featured_products",
      "category": "t:categories.products",
      "settings": {
        "gap": 32
      },
      "blocks": [
        {
          "type": "group",
          "settings": {
            "direction": "row",
            "alignment": "start",
            "alignment_vertical": "center",
            "width": "fill"
          },
          "blocks": [
            {
              "type": "heading",
              "settings": {
                "title": "t:defaults.product_list",
                "size": "h4"
              }
            },
            {
              "type": "view-all-button",
              "settings": {
                "label": "t:defaults.view_all_button"
              }
            }
          ]
        },
        {
          "type": "products",
          "settings": {
            "products_source": {"kind": "category", "id": "0"},
            "format": "slider",
            "columns": "4",
            "columns_mobile": "2"
          }
        }
      ]
    },
    {
      "name": "t:names.featured_products",
      "category": "t:categories.products",
      "settings": {
        "gap": 32,
        "alignment": "center"
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.product_list",
            "size": "h4",
            "width": "fill"
          }
        },
        {
          "type": "products",
          "settings": {
            "products_source": {"kind": "category", "id": "0"},
            "format": "slider",
            "columns": "5",
            "columns_mobile": "2"
          }
        },
        {
          "type": "view-all-button",
          "settings": {
            "label": "t:defaults.view_all_button"
          }
        }
      ]
    },
    {
      "name": "t:names.featured_products",
      "category": "t:categories.products",
      "settings": {
        "gap": 32,
        "alignment": "center"
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.product_list",
            "size": "h4",
            "width": "fill"
          }
        },
        {
          "type": "products",
          "settings": {
            "products_source": {"kind": "collection", "id": "primary"},
            "format": "grid",
            "columns": "3",
            "columns_mobile": "1"
          }
        },
        {
          "type": "view-all-button",
          "settings": {
            "label": "t:defaults.view_all_button"
          }
        }
      ]
    }
  ]
}
{% endschema %}
