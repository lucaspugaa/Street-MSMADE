{# Divider Block - Public, can be used anywhere #}

{% set divider_settings = block.settings %}
{% set padding = divider_settings.padding | default(16) %}
{% set show_line = divider_settings.show_line %}
{% set line_color = divider_settings.line_color %}

{% set divider_styles %}
	--divider-block-padding: {{ padding }}px;
	{% if line_color and show_line %}--divider-line-color: {{ line_color }};{% endif %}
{% endset %}

<div
	class="divider-block block-fill"
	{{ block | block_attributes }}
	data-store="divider-block-{{ block.id }}"
	style="{{ divider_styles | trim }}"
>
	{% if show_line %}
		<hr class="divider-line">
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.divider",
  "tags": ["general"],
  "category": "layout",
  "icon": "MiddleAlignmentIcon",
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "padding",
      "label": "t:settings.padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "MarginIcon"
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
      "visible_if": "{{ block.settings.show_line }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.divider",
      "category": "t:categories.layout",
      "settings": {
        "padding": 16,
        "show_line": true
      }
    }
  ]
}
{% endschema %}
