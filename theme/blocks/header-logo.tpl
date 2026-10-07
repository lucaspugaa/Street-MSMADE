{# Header Logo - Store logo (image or text fallback) #}

<div class="logo-container" {{ block | block_attributes }}>
	{% if has_logo %}
		{% include 'snippets/logo/logo-img.tpl' %}
	{% else %}
		{% include 'snippets/logo/logo-text.tpl' %}
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.logo",
  "icon": "FingerprintIcon",
  "limit": 1,
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "height",
      "label": "t:settings.height",
      "min": 20,
      "max": 140,
      "step": 2,
      "unit": "px",
      "default": 50,
      "icon": "height"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_height",
      "label": "t:settings.use_different_mobile_height",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "height_mobile",
      "label": "t:settings.height",
      "min": 20,
      "max": 90,
      "step": 2,
      "unit": "px",
      "default": 30,
      "icon": "height",
      "visible_if": "{{ block.settings.use_different_mobile_height }}"
    },
    {
      "type": "paragraph",
      "content": "t:content.logo_settings_info"
    }
  ]
}
{% endschema %}
