{# FAQ List Block - Container for FAQ items #}

{% set gap = block.settings.gap %}
{% set vertical_padding = block.settings.vertical_padding %}
{% set horizontal_padding = block.settings.horizontal_padding %}

<div
	class="faq-list"
	{{ block | block_attributes }}
	data-store="faq-list-{{ block.id }}"
	style="gap: {{ gap }}px; {% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %} {% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}"
>
	{% for child_block in block.blocks %}
		{% if child_block and child_block.type is defined %}
			{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
		{% endif %}
	{% endfor %}
</div>

{% schema %}
{
  "name": "t:names.faq_list",
  "icon": "ListIcon",
  "deletable": false,
  "limit": 1,
  "blocks": [
    { "type": "faq-item" }
  ],
  "settings": [
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
      "default": 0,
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
    }
  ],
  "presets": [
    {
      "name": "t:names.faq_list",
      "category": "t:categories.content",
      "blocks": [
        {
          "type": "faq-item",
          "settings": {
            "question": "t:defaults.faq.question_1",
            "answer": "t:defaults.faq.answer_1"
          }
        },
        {
          "type": "faq-item",
          "settings": {
            "question": "t:defaults.faq.question_2",
            "answer": "t:defaults.faq.answer_2"
          }
        },
        {
          "type": "faq-item",
          "settings": {
            "question": "t:defaults.faq.question_3",
            "answer": "t:defaults.faq.answer_3"
          }
        }
      ]
    }
  ]
}
{% endschema %}
