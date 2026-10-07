{# Rich Text Section (Institutional Message) #}

{# Data store for backward compatibility - first section gets legacy, others get dynamic #}
{% set data_store_value = claim_legacy_data_store('home-institutional-message') ? 'home-institutional-message' : section.id %}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set alignment = section.settings.alignment %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Align items utility: left -> start, center -> center, right -> end #}
{% set align_items_class = alignment == 'left' ? 'align-items-start' : (alignment == 'right' ? 'align-items-end' : 'align-items-center') %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}


<div
	class="rich-text-section {% if full_width %}section-full-width{% endif %}"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
			<div class="rich-text d-flex flex-column text-{{ alignment }} {{ align_items_class }}" style="gap: {{ gap | default(16) }}px;">
				{% for block in section.blocks %}
					{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
				{% endfor %}
			</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.text_editorial",
  "icon": "TextSizeIcon",
  "add_section_order": 8,
  "class": "section section-rich-text",
  "blocks": [
    { "tags": ["general"] }
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
      "default": "center"
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
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
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
    }
  ],
  "enabled_on": {
    "page_templates": "all",
    "layout_templates": ["footer"]
  },
  "presets": [
    {
      "name": "t:names.text_editorial",
      "category": "t:categories.content",
      "settings": {
        "alignment": "center",
        "gap": 16
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.rich_text.heading",
            "size": "h4"
          }
        },
        {
          "type": "text",
          "settings": {
            "text": "t:defaults.rich_text.description"
          }
        },
        {
          "type": "button",
          "settings": {
            "label": "t:defaults.rich_text.button"
          }
        }
      ]
    }
  ]
}
{% endschema %}
