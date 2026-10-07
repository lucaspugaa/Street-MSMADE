{# Divider Section #}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}
{% set show_line = section.settings.show_line %}
{% set line_color = section.settings.line_color %}

{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}

<div
	class="divider-section {% if full_width %}section-full-width{% endif %}"
	data-store="divider-section-{{ section.id }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
			{% if show_line %}
				<hr class="divider-line" {% if line_color %}style="border-color: {{ line_color }};"{% endif %}>
			{% endif %}
	{% if page_width %}
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.divider",
  "icon": "MiddleAlignmentIcon",
  "class": "section section-divider",
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
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_line",
      "label": "t:settings.divider_line",
      "default": true,
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "line_color",
      "label": "t:settings.line_color",
      "default_setting": "text_color",
      "visible_if": "{{ section.settings.show_line }}"
    }
  ],
  "enabled_on": {
    "page_templates": "all",
    "layout_templates": ["header", "footer"]
  },
  "presets": [
    {
      "name": "t:names.divider",
      "category": "t:categories.layout",
      "settings": {
        "section_width": "page",
        "vertical_padding": 64,
        "show_line": true
      }
    }
  ]
}
{% endschema %}
