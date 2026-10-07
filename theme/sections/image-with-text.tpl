{# Image with Text Section #}

{# Data store for backward compatibility #}
{% set data_store_value = claim_legacy_data_store('home-image-text-module') ? 'home-image-text-module' : section.id %}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set gap = section.settings.gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (section.settings.horizontal_padding | default(0)) %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}


<div
	{% if full_width %}class="section-full-width"{% endif %}
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
		<div style="display: flex; flex-direction: column; gap: {{ gap }}px;">
			{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
			{% for block in section.blocks %}
				{% if block.type == 'image-with-text' %}
					{% include 'blocks/image-with-text.tpl' with { block: block, is_priority: is_priority_section and loop.first, block_index: loop.index0 } %}
				{% endif %}
			{% endfor %}
		</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.image_with_text_modules",
  "icon": "ImageTextIcon",
  "add_section_order": 9,
  "class": "section section-image-with-text",
  "blocks": [
    { "type": "image-with-text" }
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
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.image_with_text_modules",
      "category": "t:categories.media",
      "blocks": [
        {
          "type": "image-with-text",
          "settings": { "gap": 0 },
          "blocks": [
            { "type": "image" },
            {
              "type": "text-group",
              "settings": { "alignment": "start", "gap": 16, "vertical_padding": 32, "horizontal_padding": 32 },
              "blocks": [
                { "type": "heading", "settings": { "title": "t:defaults.image_with_text.heading", "size": "h4" } },
                { "type": "text", "settings": { "text": "t:defaults.image_with_text.description" } },
                { "type": "button", "settings": { "label": "t:defaults.image_with_text.button", "link": "#", "style": "primary" } }
              ]
            }
          ]
        },
        {
          "type": "image-with-text",
          "settings": { "gap": 0 },
          "blocks": [
            {
              "type": "text-group",
              "settings": { "alignment": "start", "gap": 16, "vertical_padding": 32, "horizontal_padding": 32 },
              "blocks": [
                { "type": "heading", "settings": { "title": "t:defaults.image_with_text.heading", "size": "h4" } },
                { "type": "text", "settings": { "text": "t:defaults.image_with_text.description" } },
                { "type": "button", "settings": { "label": "t:defaults.image_with_text.button", "link": "#", "style": "primary" } }
              ]
            },
            { "type": "image" }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
