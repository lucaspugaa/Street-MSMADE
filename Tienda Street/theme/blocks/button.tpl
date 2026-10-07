{# Button Block - Public, can be used anywhere #}

{% set btn_settings = block.settings %}
{% set block_width = btn_settings.width | default('fit') %}
{% set btn_variant = btn_settings.variant | default('primary') %}

{% set btn_size = btn_settings.size %}
{% set btn_style = btn_variant == 'secondary' ? settings.button_secondary_style : (btn_variant == 'tertiary' ? settings.button_tertiary_style : settings.button_primary_style) %}

{# Size classes mapping #}
{% set size_class = btn_size == 'small' ? 'btn-small' : (btn_size == 'medium' ? 'btn-medium' : 'btn-big') %}

{# Resolve custom color overrides based on variant #}
{% if btn_variant == 'secondary' %}
	{% set custom_background = btn_settings.custom_background_color_secondary %}
	{% set custom_foreground = btn_settings.custom_text_color_secondary %}
{% elseif btn_variant == 'tertiary' %}
	{% set custom_background = btn_settings.custom_background_color_tertiary %}
	{% set custom_foreground = btn_settings.custom_text_color_tertiary %}
{% else %}
	{% set custom_background = btn_settings.custom_background_color %}
	{% set custom_foreground = btn_settings.custom_text_color %}
{% endif %}

{# Build inline styles - button color overrides #}
{% set btn_styles %}
	{% if block_width == 'fill' %}text-align: center;{% endif %}
	{% if custom_background and btn_style != 'underlined' %}background-color: {{ custom_background }};{% endif %}
	{% if custom_foreground %}color: {{ custom_foreground }};{% endif %}
	{% if custom_foreground and btn_style == 'outline' %}border-color: {{ custom_foreground }};{% endif %}
{% endset %}

{% if btn_settings.label %}
	<a
		href="{{ btn_settings.link }}"
		class="btn btn-{{ btn_variant }} {{ size_class }} {% if btn_style == 'underlined' %}btn-underlined{% endif %} {% if block_width == 'fill' %}block-fill{% endif %}"
		{{ block | block_attributes }}
		data-store="button-block-{{ block.id }}"
		{% if btn_styles | trim %}style="{{ btn_styles | trim }}"{% endif %}
	>
		{{ btn_settings.label }}
	</a>
{% endif %}

{% schema %}
{
  "name": "t:names.button",
  "tags": ["general"],
  "category": "basic",
  "icon": "buttons",
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "label",
      "label": "t:settings.button_text",
      "default": "t:defaults.button"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.button_link",
      "default": "#"
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
      "default": "fit"
    },
    {
      "type": "header",
      "content": "t:settings.style"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "variant",
      "options": [
        { "value": "primary", "label": "t:settings.primary_button" },
        { "value": "secondary", "label": "t:settings.secondary_button" },
        { "value": "tertiary", "label": "t:settings.tertiary_button" }
      ],
      "default": "primary"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "size",
      "label": "t:settings.size",
      "options": [
        { "value": "small", "label": "t:options.small" },
        { "value": "medium", "label": "t:options.medium" },
        { "value": "big", "label": "t:options.large" }
      ],
      "default": "big"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color",
      "label": "t:settings.background",
      "default_setting": "button_primary_background_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color",
      "label": "t:settings.text_color",
      "default_setting": "button_primary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'primary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color_secondary",
      "label": "t:settings.background",
      "default_setting": "button_secondary_background_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}",
      "disabled_if": "{{ settings.button_secondary_style == 'underlined' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color_secondary",
      "label": "t:settings.text_color",
      "default_setting": "button_secondary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'secondary' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_background_color_tertiary",
      "label": "t:settings.background",
      "default_setting": "button_tertiary_background_color",
      "visible_if": "{{ block.settings.variant == 'tertiary' }}",
      "disabled_if": "{{ settings.button_tertiary_style == 'underlined' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "custom_text_color_tertiary",
      "label": "t:settings.text_color",
      "default_setting": "button_tertiary_foreground_color",
      "visible_if": "{{ block.settings.variant == 'tertiary' }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.button",
      "category": "t:categories.basic",
      "settings": {
        "label": "t:defaults.button"
      }
    }
  ]
}
{% endschema %}
