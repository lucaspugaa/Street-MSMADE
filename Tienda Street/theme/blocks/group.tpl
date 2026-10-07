{# Group Block - Container for other blocks #}

{% set group_settings = block.settings %}
{% set block_width = group_settings.width | default('fill') %}

{% set gap = group_settings.gap | default(16) %}
{% set vertical_padding = group_settings.vertical_padding | default(0) %}
{% set horizontal_padding = group_settings.horizontal_padding | default(0) %}

{% set custom_color_style = '' %}
{% if group_settings.custom_background_color %}
	{% set custom_color_style = custom_color_style ~ 'background-color: ' ~ group_settings.custom_background_color ~ ';' %}
{% endif %}
{% if group_settings.custom_text_color %}
	{% set custom_color_style = custom_color_style ~ 'color: ' ~ group_settings.custom_text_color ~ ';' %}
{% endif %}

{# Direction classes #}
{% set mobile_direction = group_settings.mobile_direction_enabled ? group_settings.mobile_direction : group_settings.direction %}
{% if group_settings.mobile_direction_enabled and mobile_direction != group_settings.direction %}
	{% if group_settings.direction == 'row' %}
		{% set direction_class = 'flex-column flex-md-row flex-wrap' %}
	{% else %}
		{% set direction_class = 'flex-row flex-wrap flex-md-column' %}
	{% endif %}
{% else %}
	{% set direction_class = group_settings.direction == 'row' ? 'flex-row flex-wrap' : 'flex-column' %}
{% endif %}

{# Map alignment intent to the right flex axis per direction. Add `-md-` overrides when desktop direction differs from mobile. #}
{% set horizontal_align = group_settings.alignment == 'center' ? 'center' : (group_settings.alignment == 'end' ? 'end' : 'start') %}
{% set vertical_align = group_settings.alignment_vertical == 'center' ? 'center' : (group_settings.alignment_vertical == 'bottom' ? 'end' : 'start') %}
{% set text_align = group_settings.alignment == 'center' ? 'center' : (group_settings.alignment == 'end' ? 'right' : 'left') %}

{% set horizontal_axis = { 'row': 'justify-content', 'column': 'align-items' } %}
{% set vertical_axis = { 'row': 'align-items', 'column': 'justify-content' } %}

{% set align_class = horizontal_axis[mobile_direction] ~ '-' ~ horizontal_align %}
{% set vertical_align_class = vertical_axis[mobile_direction] ~ '-' ~ vertical_align %}
{% if group_settings.direction != mobile_direction %}
	{% set align_class = align_class ~ ' ' ~ horizontal_axis[group_settings.direction] ~ '-md-' ~ horizontal_align %}
	{% set vertical_align_class = vertical_align_class ~ ' ' ~ vertical_axis[group_settings.direction] ~ '-md-' ~ vertical_align %}
{% endif %}

<div 
	class="group-block d-flex {{ direction_class }} {{ align_class }} {% if block_width == 'fill' %}block-fill{% endif %}" 
	style="gap: {{ gap }}px; text-align: {{ text_align }};{% if vertical_padding or horizontal_padding %} padding: {{ vertical_padding }}px {{ horizontal_padding }}px;{% endif %} {{ custom_color_style }}"
	{{ block | block_attributes }}
	data-store="group-block-{{ block.id }}"
>
	{# Content #}
	{% if group_settings.direction == 'row' %}
		{% set content_class = mobile_direction == 'row' ? 'group-content-horizontal' : 'group-content-horizontal-md' %}
	{% elseif mobile_direction == 'row' %}
		{% set content_class = 'group-content-horizontal-md ' ~ direction_class %}
	{% else %}
		{% set content_class = 'd-flex ' ~ direction_class %}
	{% endif %}
	<div class="group-content {{ content_class }} {{ align_class }} {{ vertical_align_class }}" style="gap: {{ gap | default(16) }}px;">
	{% for child_block in block.blocks %}
		{% if child_block and child_block.type is defined %}
			{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
		{% endif %}
	{% endfor %}
	</div>
</div>

{% schema %}
{
  "name": "t:names.group",
  "tags": ["general"],
  "category": "layout",
  "icon": "folder",
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
      "default": "column"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "mobile_direction_enabled",
      "label": "t:settings.mobile_direction"
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
      "visible_if": "{{ block.settings.mobile_direction_enabled }}"
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
      "vertical_default": "top"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "fit", "label": "t:options.fit" },
        { "value": "fill", "label": "t:options.fill" }
      ],
      "default": "fill"
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
      "default": 0,
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
      "icon": "horizontal_padding"
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
      "name": "t:names.group",
      "category": "t:categories.layout"
    }
  ]
}
{% endschema %}
