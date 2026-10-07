{# Video with Text Section - Video block + content side by side #}
{# Block order determines left/right position in horizontal layout #}

{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
{% set theme_settings = settings %}
{% set settings = section.settings %}

{# Data store for backward compatibility #}
{% set data_store_value = claim_legacy_data_store('home-video') ? 'home-video' : section.id %}

{# Width #}
{% set page_width = settings.section_width == 'page' %}

{# Spacing #}
{% set gap = settings.gap | default(0) %}
{% set vertical_padding = settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (settings.horizontal_padding | default(0)) %}

{# Colors #}
{% set background_color = settings.background_color %}

{# Separate video blocks from content blocks #}
{% set video_blocks = [] %}
{% set content_blocks = [] %}
{% for block in section.blocks %}
	{% if block.type == 'video' %}
		{% set video_blocks = video_blocks | merge([block]) %}
	{% else %}
		{% set content_blocks = content_blocks | merge([block]) %}
	{% endif %}
{% endfor %}

{# Block order determines left/right position #}
{% set content_first = section.blocks | first and section.blocks | first.type != 'video' %}

{# Section styles #}
{% set section_styles %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}


<div
	class="video-section"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
		<div
			class="media-grid media-grid-md-horizontal {% if content_first %}media-grid-content-left{% endif %}"
			style="gap: {{ gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
		>
			{# Video column #}
			<div class="media-visual">
				{% for block in video_blocks %}
					{% include 'blocks/video.tpl' with { block: block, is_priority: is_priority_section, settings: theme_settings } %}
				{% endfor %}
			</div>

			{# Content column #}
			<div class="media-content-group">
				{% for block in content_blocks %}
					{% include 'blocks/text-group.tpl' with { block: block, settings: theme_settings } %}
				{% endfor %}
			</div>
		</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.video_with_text",
  "icon": "VideoTextIcon",
  "add_section_order": 10,
  "class": "section section-video",
  "blocks": [],
  "locked_blocks": {
    "reorderable": true
  },
  "settings": [
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
      "default": 0,
      "icon": "horizontal_spacing"
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
      "default": 0,
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
    }
  ],
  "presets": [
    {
      "name": "t:names.video_with_text",
      "category": "t:categories.media",
      "settings": {
        "section_width": "page",
        "gap": 0
      },
      "blocks": [
        {
          "type": "video",
          "settings": {
            "video_type": "autoplay"
          }
        },
        {
          "type": "text-group",
          "settings": {
            "alignment": "start",
            "gap": 16,
            "vertical_padding": 32,
            "horizontal_padding": 32
          },
          "blocks": [
            {
              "type": "heading",
              "settings": {
                "title": "t:defaults.video.heading",
                "size": "h2"
              }
            },
            {
              "type": "text",
              "settings": {
                "text": "t:defaults.video.description"
              }
            },
            {
              "type": "button",
              "settings": {
                "label": "t:defaults.video.button"
              }
            }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
