{# Text Block - Public, can be used anywhere #}

{% set text_settings = block.settings %}
{% set block_width = text_settings.width | default('fill') %}
{% set text_size_class = text_settings.size == 'paragraph_small' ? 'font-small' : text_settings.size == 'paragraph_big' ? 'font-big' %}
{% set text_align_class = text_settings.text_alignment ? 'text-' ~ text_settings.text_alignment : '' %}

<div class="text-block {% if block_width == 'fill' %}block-fill{% endif %}" {{ block | block_attributes }} data-store="text-block-{{ block.id }}">
	{% if text_settings.text %}
		<div class="text-content user-content {{ text_size_class }} {{ text_align_class }}">
			{{ text_settings.text | raw }}
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.text",
  "tags": ["general"],
  "category": "basic",
  "icon": "AlignLeftIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "text",
      "label": "t:options.text",
      "default": "t:defaults.text"
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
      "type": "header",
      "content": "t:names.text_settings"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "size",
      "label": "t:settings.size",
      "options": [
        { "value": "paragraph_small", "label": "t:options.small" },
        { "value": "paragraph", "label": "t:options.medium" },
        { "value": "paragraph_big", "label": "t:options.large" }
      ],
      "default": "paragraph"
    }
  ],
  "presets": [
    {
      "name": "t:names.text",
      "category": "t:categories.basic",
      "settings": {
        "text": "t:defaults.text"
      }
    }
  ]
}
{% endschema %}
