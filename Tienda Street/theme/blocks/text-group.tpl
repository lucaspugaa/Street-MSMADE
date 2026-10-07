{# Text Group Block - Container for other blocks #}

{% set group_settings = block.settings %}

{% set gap = group_settings.gap | default(16) %}
{% set vertical_padding = group_settings.vertical_padding | default(32) %}
{% set horizontal_padding = group_settings.horizontal_padding | default(32) %}

{% set custom_color_style = '' %}
{% if group_settings.custom_background_color %}
	{% set custom_color_style = custom_color_style ~ 'background-color: ' ~ group_settings.custom_background_color ~ ';' %}
{% endif %}
{% if group_settings.custom_text_color %}
	{% set custom_color_style = custom_color_style ~ 'color: ' ~ group_settings.custom_text_color ~ ';' %}
{% endif %}

{# Horizontal alignment #}
{% if group_settings.alignment == 'center' %}
	{% set align_class = 'align-items-center' %}
	{% set text_align_class = 'text-center' %}
{% elseif group_settings.alignment == 'end' %}
	{% set align_class = 'align-items-end' %}
	{% set text_align_class = 'text-right' %}
{% else %}
	{% set align_class = 'align-items-start' %}
	{% set text_align_class = 'text-left' %}
{% endif %}

{# Vertical alignment — default center, matching vertical_default in schema #}
{% if group_settings.alignment_vertical == 'top' %}
	{% set vertical_align_class = 'justify-content-start' %}
{% elseif group_settings.alignment_vertical == 'bottom' %}
	{% set vertical_align_class = 'justify-content-end' %}
{% else %}
	{% set vertical_align_class = 'justify-content-center' %}
{% endif %}

<div
	class="group-block d-flex flex-column {{ align_class }} {{ vertical_align_class }} {{ text_align_class }}"
	style="height: 100%; gap: {{ gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px; {{ custom_color_style }}"
	{{ block | block_attributes }}
	data-store="group-block-{{ block.id }}"
>
	<div class="group-content d-flex flex-column {{ align_class }}" style="gap: {{ gap }}px;">
		{% for child_block in block.blocks %}
			{% if child_block and child_block.type is defined %}
				{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
			{% endif %}
		{% endfor %}
	</div>
</div>

{% schema %}
{
  "name": "t:names.text",
  "icon": "folder",
  "blocks": [
    { "tags": ["general"] }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:content.layout"
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
      "name": "t:names.text",
      "category": "t:categories.layout"
    }
  ]
}
{% endschema %}
