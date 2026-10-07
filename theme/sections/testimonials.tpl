{# Testimonials Section #}

{% set data_store_value = claim_legacy_data_store('home-testimonials') ? 'home-testimonials' : section.id %}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set alignment = section.settings.alignment %}
{% set align_items = alignment == 'center' ? 'center' : (alignment == 'right' ? 'flex-end' : 'flex-start') %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Section styles #}
{% set section_styles %}
	{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
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
  "name": "t:names.testimonials",
  "icon": "QuoteIcon",
  "add_section_order": 13,
  "class": "section section-testimonials",
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
      "default": "center"
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
    }
  ],
  "presets": [
    {
      "name": "t:names.testimonials",
      "category": "t:categories.content",
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.testimonials.heading",
            "size": "h4"
          }
        },
        {
          "type": "testimonial-group",
          "settings": {
            "alignment": "center",
            "format": "grid",
            "columns": "3",
            "gap": 16,
            "image_style": "rounded",
            "avatar_layout": "top"
          },
          "blocks": [
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_1",
                "rating": "5",
                "title": "t:defaults.testimonials.title_1",
                "content": "t:defaults.testimonials.content_1"
              }
            },
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_2",
                "rating": "5",
                "title": "t:defaults.testimonials.title_2",
                "content": "t:defaults.testimonials.content_2"
              }
            },
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_3",
                "rating": "4",
                "title": "t:defaults.testimonials.title_3",
                "content": "t:defaults.testimonials.content_3"
              }
            }
          ]
        }
      ]
    },
    {
      "name": "t:names.testimonials",
      "category": "t:categories.content",
      "settings": {
        "alignment": "left"
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.testimonials.heading",
            "size": "h4"
          }
        },
        {
          "type": "testimonial-group",
          "settings": {
            "alignment": "left",
            "format": "carousel",
            "columns": "2",
            "gap": 16,
            "image_style": "rounded",
            "avatar_layout": "left"
          },
          "blocks": [
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_1",
                "rating": "none",
                "title": "t:defaults.testimonials.content_1",
                "content": ""
              }
            },
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_2",
                "rating": "none",
                "title": "t:defaults.testimonials.content_2",
                "content": ""
              }
            },
            {
              "type": "testimonial",
              "settings": {
                "name": "t:defaults.testimonials.name_3",
                "rating": "none",
                "title": "t:defaults.testimonials.content_3",
                "content": ""
              }
            }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
