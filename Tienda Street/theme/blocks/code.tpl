{# Code Block - Raw HTML/JS/CSS injection. Only addable inside the Custom section. #}

{% set code = block.settings.code %}
{% set block_width = block.settings.width | default('fill') %}

{% if code %}
	<div class="code-block {% if block_width == 'fill' %}block-fill{% endif %}" {{ block | block_attributes }} data-store="code-block-{{ block.id }}">
		{{ code | raw }}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.code",
  "icon": "CodeIcon",
  "tags": ["general"],
  "settings": [
    {
      "type": "setting",
      "setting_type": "custom_code",
      "id": "code",
      "label": "t:settings.code"
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
    }
  ]
}
{% endschema %}
