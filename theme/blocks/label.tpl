{# Label Block - Public, can be used anywhere #}

{% set label_settings = block.settings %}
{% set label_variant = label_settings.variant | default('primary') %}

{# Resolve custom color overrides based on variant #}
{% if label_variant == 'secondary' %}
	{% set custom_background = label_settings.custom_background_color_secondary %}
	{% set custom_foreground = label_settings.custom_text_color_secondary %}
	{% set label_style = settings.label_shipping_style %}
{% else %}
	{% set custom_background = label_settings.custom_background_color %}
	{% set custom_foreground = label_settings.custom_text_color %}
	{% set label_style = settings.label_style %}
{% endif %}

{# Build inline styles - label color overrides #}
{% set label_styles %}
	{% if custom_background and label_style != 'outline' %}background-color: {{ custom_background }};{% endif %}
	{% if custom_foreground %}color: {{ custom_foreground }};{% endif %}
	{% if custom_foreground and label_style == 'outline' %}border-color: {{ custom_foreground }};{% endif %}
{% endset %}

{% if label_settings.text %}
	<span
		class="label-block label {% if label_variant == 'primary' %}label-primary{% else %}label-secondary{% endif %}"
		{{ block | block_attributes }}
		data-store="label-block-{{ block.id }}"
		{% if label_styles | trim %}style="{{ label_styles | trim }}"{% endif %}
	>
		{{ label_settings.text }}
	</span>
{% endif %}

{% schema %}
{
  "name": "t:names.label",
  "tags": ["general"],
  "category": "basic",
  "icon": "FlagIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "text",
      "label": "t:settings.label_text",
      "default": "t:defaults.label"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "variant",
      "label": "t:settings.style",
      "options": [
        { "value": "primary", "label": "t:settings.primary_label" },
        { "value": "secondary", "label": "t:settings.secondary_label" }
      ],
      "default": "primary"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color",
      "label": "t:settings.background",
      "default_setting": "label_background_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color",
      "label": "t:settings.text_color",
      "default_setting": "label_foreground_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color_secondary",
      "label": "t:settings.background",
      "default_setting": "label_shipping_background_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color_secondary",
      "label": "t:settings.text_color",
      "default_setting": "label_shipping_foreground_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.label",
      "category": "t:categories.basic",
      "settings": {
        "text": "t:defaults.label"
      }
    }
  ]
}
{% endschema %}
