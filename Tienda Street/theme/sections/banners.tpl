{# Banners Section #}
{# Supports both group blocks (flexible) and banner blocks (simplified) #}

{% set has_banners = section.blocks | length > 0 %}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set columns = section.settings.columns %}
{% set columns_mobile = section.settings.columns_mobile %}
{% set format = section.settings.format %}
{% set format_mobile = section.settings.use_different_mobile_format ? section.settings.format_mobile : format %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}

{# Data store: first section gets legacy home-banner-categories, others get dynamic #}
{% set banners_data_store = claim_legacy_data_store('home-banner-categories') ? 'home-banner-categories' : section.id %}

{# Single DOM: slider + grid via responsive flexbox classes #}
{% set use_slider = format_mobile == 'slider' or format == 'slider' %}
{% set slider_both = format_mobile == 'slider' and format == 'slider' %}
{% set slider_mobile_only = format_mobile == 'slider' and format == 'grid' %}
{% set slider_desktop_only = format == 'slider' and format_mobile == 'grid' %}

{% set section_wrapper_classes = 
	slider_both ? 'swiper-wrapper flex-nowrap' : 
	slider_mobile_only ? 'swiper-wrapper swiper-mobile-only flex-grid flex-nowrap flex-md-wrap' : 
	slider_desktop_only ? 'swiper-wrapper swiper-desktop-only flex-grid flex-wrap flex-md-nowrap' :
	'flex-grid'
%}

{% if slider_mobile_only %}
	{% set section_arrows_visibility = 'd-none' %}
{% endif %}

{% set section_pagination_visibility = slider_both ? '' : slider_mobile_only ? 'd-block d-md-none' : slider_desktop_only ? 'd-none d-md-block' %}

{# Section styles #}
{% set section_styles %}
	{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}


<div 
	class="banners-section {% if full_width %}banners-section-full-width section-full-width{% endif %}"
	data-store="{{ banners_data_store }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
		{% if has_banners %}
			{% if use_slider %}
				<div class="js-banners-slider-container position-relative banners-slider-wrapper" data-columns-desktop="{{ columns }}" data-columns-mobile="{{ columns_mobile }}" data-gap-horizontal="{{ gap }}" data-desktop-format="{{ format }}" data-mobile-format="{{ format_mobile }}">
					<div class="js-banners-slider swiper-container">
			{% endif %}
						<div class="{{ section_wrapper_classes }}"
							style="--cols: {{ columns_mobile }}; --cols-md: {{ columns }}; --grid-gap: {{ gap }}px; row-gap: {{ gap }}px;">
							{# On pages with page-header (category, search), prioritize sections 1 and 2 since page-header occupies one slot but rarely contains images #}
							{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
							{% for block in section.blocks %}
								{% if block.type == 'banner' %}
									<div class="{% if use_slider %}swiper-slide{% endif %} banner-item">
										{% include 'blocks/banner.tpl' with {
											block: block,
											is_priority: is_priority_section and loop.first,
											block_index: loop.index0,
											banner_aspect_ratio: section.settings.banner_aspect_ratio | default('original'),
											banner_aspect_ratio_height: section.settings.banner_aspect_ratio_height | default(100),
											banner_aspect_ratio_mobile: section.settings.use_different_mobile_aspect_ratio ? section.settings.banner_aspect_ratio_mobile | default('original') : null,
											banner_aspect_ratio_mobile_height: section.settings.use_different_mobile_aspect_ratio ? section.settings.banner_aspect_ratio_mobile_height | default(100) : null
										} %}
									</div>
								{% endif %}
							{% endfor %}
						</div>
			{% if use_slider %}
					</div>
					{% if section.blocks | length > 1 %}
						<button type="button" class="js-swiper-banners-prev swiper-button-prev swiper-button-outside {{ section_arrows_visibility }}" aria-label="{{ 'general.previous' | t }}">
							<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
						</button>
						<button type="button" class="js-swiper-banners-next swiper-button-next swiper-button-outside {{ section_arrows_visibility }}" aria-label="{{ 'general.next' | t }}">
							<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
						</button>
					{% endif %}
					{% if section.blocks | length > 1 %}
						<div class="js-swiper-banners-pagination swiper-pagination swiper-pagination-bullets swiper-pagination-outside {{ section_pagination_visibility }}"></div>
					{% endif %}
				</div>
			{% endif %}
		{% endif %}
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.banners",
  "add_section_order": 3,
  "class": "section section-banners",
  
  "blocks": [
    { "type": "banner" }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "format",
      "label": "t:settings.format",
      "options": [
        { "value": "grid", "label": "t:options.grid" },
        { "value": "slider", "label": "t:options.slider" }
      ],
      "default": "grid"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_format",
      "label": "t:settings.use_different_mobile_format",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "format_mobile",
      "label": "t:settings.format_mobile",
      "options": [
        { "value": "grid", "label": "t:options.grid" },
        { "value": "slider", "label": "t:options.slider" }
      ],
      "default": "slider",
      "visible_if": "{{ section.settings.use_different_mobile_format }}"
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
        { "value": "3", "label": "t:options.columns_3" },
        { "value": "4", "label": "t:options.columns_4" }
      ],
      "default": "3"
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
      "default": "1"
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
      "setting_type": "select",
      "id": "banner_aspect_ratio",
      "label": "t:settings.image_format",
      "icon": "ArrowsDiagonalOutIcon",
      "options": [
        { "value": "original", "label": "t:options.aspect_original" },
        { "value": "square", "label": "t:options.aspect_square" },
        { "value": "horizontal", "label": "t:options.aspect_horizontal" },
        { "value": "vertical", "label": "t:options.aspect_vertical" },
        { "value": "custom", "label": "t:options.aspect_custom" }
      ],
      "default": "original"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "banner_aspect_ratio_height",
      "label": "t:settings.image_height",
      "min": 5,
      "max": 200,
      "step": 5,
      "unit": "%",
      "default": 100,
      "icon": "height",
      "visible_if": "{{ section.settings.banner_aspect_ratio == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_aspect_ratio",
      "label": "t:settings.use_different_mobile_format",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "banner_aspect_ratio_mobile",
      "label": "t:settings.image_mobile_format",
      "icon": "ArrowsDiagonalOutIcon",
      "options": [
        { "value": "original", "label": "t:options.aspect_original" },
        { "value": "square", "label": "t:options.aspect_square" },
        { "value": "horizontal", "label": "t:options.aspect_horizontal" },
        { "value": "vertical", "label": "t:options.aspect_vertical" },
        { "value": "custom", "label": "t:options.aspect_custom" }
      ],
      "default": "original",
      "visible_if": "{{ section.settings.use_different_mobile_aspect_ratio }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "banner_aspect_ratio_mobile_height",
      "label": "t:settings.image_mobile_height",
      "min": 5,
      "max": 200,
      "step": 5,
      "unit": "%",
      "default": 100,
      "icon": "height",
      "visible_if": "{{ section.settings.use_different_mobile_aspect_ratio and section.settings.banner_aspect_ratio_mobile == 'custom' }}"
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
      "default": 16,
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
      "default": 0,
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
  "enabled_on": {
    "page_templates": "all",
    "layout_templates": ["footer"]
  },
  "presets": [
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "2",
        "columns_mobile": "1",
        "gap": 0,
        "vertical_padding": 0,
        "horizontal_padding": 0,
        "section_width": "full",
        "banner_aspect_ratio": "square"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 32, "horizontal_padding": 32, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h1" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "size": "medium" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 32, "horizontal_padding": 32, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h1" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "size": "medium" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "2",
        "columns_mobile": "1",
        "gap": 16,
        "vertical_padding": 64,
        "horizontal_padding": 0,
        "section_width": "page",
        "banner_aspect_ratio": "horizontal"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 8, "vertical_padding": 24, "horizontal_padding": 0, "alignment": "center", "alignment_vertical": "center", "text_outside": true  },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h2" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 8, "vertical_padding": 24, "horizontal_padding": 0, "alignment": "center", "alignment_vertical": "center", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h2" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "3",
        "columns_mobile": "1",
        "gap": 16,
        "vertical_padding": 40,
        "banner_aspect_ratio": "square"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "3",
        "columns_mobile": "1",
        "gap": 0,
        "vertical_padding": 0,
        "horizontal_padding": 0,
        "section_width": "full",
        "banner_aspect_ratio": "vertical"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 8, "vertical_padding": 24, "horizontal_padding": 24 },
          "blocks": [
            { "type": "text", "settings": { "text": "t:defaults.banner.description", "size": "paragraph_small" } },
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h2" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 8, "vertical_padding": 24, "horizontal_padding": 24 },
          "blocks": [
            { "type": "text", "settings": { "text": "t:defaults.banner.description", "size": "paragraph_small" } },
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h2" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 8, "vertical_padding": 24, "horizontal_padding": 24 },
          "blocks": [
            { "type": "text", "settings": { "text": "t:defaults.banner.description", "size": "paragraph_small" } },
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h2" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "4",
        "columns_mobile": "1",
        "gap": 0,
        "vertical_padding": 0,
        "horizontal_padding": 0,
        "section_width": "full",
        "banner_aspect_ratio": "square"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 24, "horizontal_padding": 24, "alignment": "center", "alignment_vertical": "center" },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "4",
        "columns_mobile": "1",
        "gap": 16,
        "vertical_padding": 24,
        "horizontal_padding": 24,
        "section_width": "full",
        "banner_aspect_ratio": "vertical"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 16, "horizontal_padding": 12, "alignment": "start", "alignment_vertical": "bottom", "text_outside": true  },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "variant": "tertiary", "size": "medium" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 16, "horizontal_padding": 12, "alignment": "start", "alignment_vertical": "bottom", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "variant": "tertiary", "size": "medium" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 16, "horizontal_padding": 12, "alignment": "start", "alignment_vertical": "bottom", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "variant": "tertiary", "size": "medium" } }
          ]
        },
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 16, "horizontal_padding": 12, "alignment": "start", "alignment_vertical": "bottom", "text_outside": true },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h3" } },
            { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
            { "type": "button", "settings": { "label": "t:defaults.banner.button", "variant": "tertiary", "size": "medium" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "1",
        "columns_mobile": "1",
        "gap": 16,
        "vertical_padding": 40,
        "horizontal_padding": 40,
        "section_width": "page",
        "banner_aspect_ratio": "custom",
        "banner_aspect_ratio_height": 25,
        "use_different_mobile_aspect_ratio": true,
        "banner_aspect_ratio_mobile": "horizontal"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 32, "horizontal_padding": 32, "alignment": "start", "alignment_vertical": "center"},
          "blocks": [
            {
              "type": "group",
              "settings": {
                "direction": "row",
                "alignment_vertical": "center",
                "gap": 16,
                "vertical_padding": 0,
                "horizontal_padding": 0
              },
              "blocks": [
                {
                  "type": "group",
                    "settings": {
                      "gap": 8
                    },
                    "blocks": [
                      { "type": "heading", "settings": { "title": "t:defaults.heading", "size": "h1" } },
                      { "type": "text", "settings": { "text": "t:defaults.text" } }
                    ]
                },
                {
                  "type": "button",
                  "settings": {
                    "size": "medium"
                  }
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "name": "t:names.banners",
      "category": "t:categories.media",
      "settings": {
        "format": "grid",
        "columns": "1",
        "columns_mobile": "1",
        "gap": 16,
        "vertical_padding": 0,
        "horizontal_padding": 0,
        "section_width": "full",
        "banner_aspect_ratio": "custom",
        "banner_aspect_ratio_height": 25,
        "use_different_mobile_aspect_ratio": true,
        "banner_aspect_ratio_mobile": "horizontal"
      },
      "blocks": [
        {
          "type": "banner",
          "settings": { "gap": 16, "vertical_padding": 32, "horizontal_padding": 32, "alignment": "center", "alignment_vertical": "center"},
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h1" } },
            {
              "type": "group",
              "settings": {
                "direction": "row",
                "alignment": "center",
                "gap": 8,
                "vertical_padding": 0,
                "horizontal_padding": 0
              },
              "blocks": [
                { "type": "button", "settings": { "label": "t:defaults.banner.button", "size": "medium" } },
                { "type": "button", "settings": { "label": "t:defaults.banner.button", "size": "medium" } }
              ]
            }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
