{#
  Blog Posts Section
  Featured blog posts for any page (home, etc.).
  Post data is managed by the static blog-posts-list block via blog_post_list setting.
#}

{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set alignment = section.settings.alignment | default('left') %}
{% set align_items = alignment == 'center' ? 'center' : (alignment == 'right' ? 'flex-end' : 'flex-start') %}
{% set gap = section.settings.gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (section.settings.horizontal_padding | default(32)) %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{% set posts_block = null %}
{% for block in section.blocks %}
	{% if block.type == 'blog-posts-list' %}
		{% set posts_block = block %}
	{% endif %}
{% endfor %}
{% set has_posts = posts_block and posts_block.settings.posts | length > 0 %}

{% set section_styles %}
	{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}


{% if has_posts or is_preview %}
<div
	class="blog-posts-section {% if full_width %}section-full-width{% endif %}"
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
{% endif %}


{% schema %}
{
  "name": "t:names.blog_posts_section",
  "icon": "EditIcon",
  "add_section_order": 17,
  "class": "section section-blog-posts",
  "blocks": [
    { "tags": ["general"] },
    { "type": "blog-posts-list", "limit": 1 }
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
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.blog_posts_section",
      "category": "t:categories.content",
      "settings": {
        "section_width": "page",
        "alignment": "left",
        "gap": 32
      },
      "blocks": [
        {
          "type": "group",
          "settings": {
            "direction": "row",
            "alignment": "start",
            "alignment_vertical": "center",
            "width": "fill"
          },
          "blocks": [
            {
              "type": "heading",
              "settings": {
                "title": "t:defaults.blog_posts_section.heading",
                "size": "h4"
              }
            },
            {
              "type": "button",
              "settings": {
                "label": "t:defaults.button",
                "variant": "tertiary",
                "size": "medium",
                "link": "/blog"
              }
            }
          ]
        },
        {
          "type": "blog-posts-list",
          "settings": {
            "posts_count": 3,
            "columns_desktop": "3"
          }
        }
      ]
    },
    {
      "name": "t:names.blog_posts_section",
      "category": "t:categories.content",
      "settings": {
        "section_width": "page",
        "alignment": "center",
        "gap": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.blog_posts_section.heading",
            "size": "h4"
          }
        },
        {
          "type": "blog-posts-list",
          "limit": 1,
          "settings": {
            "posts_count": 4,
            "columns_desktop": "4"
          }
        },
        {
          "type": "button",
          "settings": {
            "label": "t:defaults.button",
            "variant": "tertiary",
            "size": "medium",
            "link": "/blog"
          }
        }
      ]
    }
  ]
}
{% endschema %}
