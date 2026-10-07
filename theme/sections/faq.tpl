{# FAQ Section - Frequently Asked Questions #}

{% set data_store_value = section.id %}

{% set alignment = section.settings.alignment %}
{% set align_items = alignment == 'center' ? 'center' : (alignment == 'right' ? 'flex-end' : 'flex-start') %}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}


<div
	{% if full_width %}class="section-full-width"{% endif %}
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
			<div class="d-flex flex-column text-{{ alignment }}" style="align-items: {{ align_items }}; gap: {{ gap }}px;">
				{% for block in section.blocks %}
					{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
				{% endfor %}
			</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.faq",
  "icon": "QuestionCircleIcon",
  "add_section_order": 15,
  "class": "section section-faq",
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
      "setting_type": "text_alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "left"
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
      "default": 32,
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
      "id": "background_color",
      "label": "t:settings.background",
      "default": "transparent"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.faq",
      "category": "t:categories.content",
      "settings": {
        "gap": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.faq.heading",
            "size": "h4"
          }
        },
        {
          "type": "faq-group",
          "settings": {
            "gap": 0
          },
          "blocks": [
            {
              "type": "image"
            },
            {
              "type": "faq-list",
              "settings": {
                "vertical_padding": 32,
                "horizontal_padding": 32
              },
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
      ]
    },
    {
      "name": "t:names.faq",
      "category": "t:categories.content",
      "settings": {
        "gap": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.faq.heading",
            "size": "h4"
          }
        },
        {
          "type": "faq-group",
          "settings": {
            "gap": 32
          },
          "blocks": [
            {
              "type": "faq-list",
              "settings": {
                "vertical_padding": 0,
                "horizontal_padding": 0
              },
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
      ]
    }
  ]
}
{% endschema %}
