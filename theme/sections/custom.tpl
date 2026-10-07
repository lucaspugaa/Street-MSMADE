{# Custom Section - Open container for composing any general blocks. Layout controls mirror group.tpl. #}

{% set section_settings = section.settings %}
{% set full_width = section_settings.section_width == 'full' %}
{% set page_width = section_settings.section_width == 'page' %}

{% set gap = section_settings.gap | default(16) %}
{% set vertical_padding = section_settings.vertical_padding | default(0) %}
{% set horizontal_padding = full_width ? section_settings.horizontal_padding | default(0) : 0 %}

{% set custom_color_style = '' %}
{% if section_settings.custom_background_color %}
	{% set custom_color_style = custom_color_style ~ 'background-color: ' ~ section_settings.custom_background_color ~ ';' %}
{% endif %}
{% if section_settings.custom_text_color %}
	{% set custom_color_style = custom_color_style ~ 'color: ' ~ section_settings.custom_text_color ~ ';' %}
{% endif %}

{# Direction classes #}
{% set mobile_direction = section_settings.mobile_direction_enabled ? section_settings.mobile_direction : section_settings.direction %}
{% if section_settings.mobile_direction_enabled and mobile_direction != section_settings.direction %}
	{% if section_settings.direction == 'row' %}
		{% set direction_class = 'flex-column flex-md-row flex-wrap' %}
	{% else %}
		{% set direction_class = 'flex-row flex-wrap flex-md-column' %}
	{% endif %}
{% else %}
	{% set direction_class = section_settings.direction == 'row' ? 'flex-row flex-wrap' : 'flex-column' %}
{% endif %}

{# Map alignment intent to the right flex axis per direction. Add `-md-` overrides when desktop direction differs from mobile. #}
{% set horizontal_align = section_settings.alignment == 'center' ? 'center' : (section_settings.alignment == 'end' ? 'end' : 'start') %}
{% set vertical_align = (section_settings.alignment_vertical | default('center')) == 'center' ? 'center' : (section_settings.alignment_vertical == 'bottom' ? 'end' : 'start') %}
{% set text_align = section_settings.alignment == 'center' ? 'center' : (section_settings.alignment == 'end' ? 'right' : 'left') %}

{% set horizontal_axis = { 'row': 'justify-content', 'column': 'align-items' } %}
{% set vertical_axis = { 'row': 'align-items', 'column': 'justify-content' } %}

{% set align_class = horizontal_axis[mobile_direction] ~ '-' ~ horizontal_align %}
{% set vertical_align_class = vertical_axis[mobile_direction] ~ '-' ~ vertical_align %}
{% if section_settings.direction != mobile_direction %}
	{% set align_class = align_class ~ ' ' ~ horizontal_axis[section_settings.direction] ~ '-md-' ~ horizontal_align %}
	{% set vertical_align_class = vertical_align_class ~ ' ' ~ vertical_axis[section_settings.direction] ~ '-md-' ~ vertical_align %}
{% endif %}

{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{{ custom_color_style }}
{% endset %}

<div
	class="section-custom {% if full_width %}section-full-width{% endif %}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
			{% if section_settings.direction == 'row' %}
				{% set content_class = mobile_direction == 'row' ? 'group-content-horizontal' : 'group-content-horizontal-md' %}
			{% elseif mobile_direction == 'row' %}
				{% set content_class = 'group-content-horizontal-md ' ~ direction_class %}
			{% else %}
				{% set content_class = 'd-flex ' ~ direction_class %}
			{% endif %}
			<div class="custom-section-content {{ content_class }} {{ align_class }} {{ vertical_align_class }}" style="gap: {{ gap }}px; text-align: {{ text_align }};">
				{% for block in section.blocks %}
					{% if block and block.type is defined %}
						{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
					{% endif %}
				{% endfor %}
			</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.custom",
  "icon": "LayoutIcon",
  "class": "section section-custom-container",
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
      "setting_type": "radio",
      "id": "direction",
      "label": "t:settings.direction",
      "options": [
        { "value": "column", "label": "t:options.vertical", "icon": "ArrowDownIcon" },
        { "value": "row", "label": "t:options.horizontal", "icon": "ArrowRightIcon" }
      ],
      "default": "row"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "mobile_direction_enabled",
      "label": "t:settings.mobile_direction",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "mobile_direction",
      "label": "t:settings.mobile_direction_value",
      "options": [
        { "value": "column", "label": "t:options.vertical", "icon": "ArrowDownIcon" },
        { "value": "row", "label": "t:options.horizontal", "icon": "ArrowRightIcon" }
      ],
      "default": "column",
      "visible_if": "{{ section.settings.mobile_direction_enabled }}"
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "start", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "end", "label": "t:options.right" }
      ],
      "default": "start",
      "vertical_options": [
        { "value": "top", "label": "t:options.top" },
        { "value": "center", "label": "t:options.center" },
        { "value": "bottom", "label": "t:options.bottom" }
      ],
      "vertical_default": "center"
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
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color",
      "label": "t:settings.background",
      "default": "transparent"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color",
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.custom",
      "category": "t:categories.layout",
      "blocks": [
        {
          "type": "group",
          "settings": {
            "gap": 8,
            "vertical_padding": 0,
            "horizontal_padding": 0
          },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.heading", "size": "h4" } },
            { "type": "text", "settings": { "text": "t:defaults.text" } }
          ]
        },
        {
          "type": "button"
        }
      ]
    }
  ]
}
{% endschema %}
