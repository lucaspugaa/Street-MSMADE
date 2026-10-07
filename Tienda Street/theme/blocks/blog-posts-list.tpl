{# Blog Posts List Block - Static internal block for blog-posts section #}

{% set posts = block.settings.posts | default([]) %}
{% set posts_count = block.settings.posts_count | default(3) %}
{% set columns_desktop = block.settings.columns_desktop | default('3') %}
{% set block_gap = block.settings.gap | default(16) %}

{% if is_preset_preview or (posts | length == 0 and is_preview) %}
	{% set posts = [] %}
	{% for i in 1..posts_count %}
		{% set placeholder_num = ((i - 1) % 6) + 1 %}
		{% set posts = posts | merge([{
			'is_placeholder': true,
			'post_id': 'placeholder-' ~ i,
			'handle': '#',
			'title': 'blog.example_title' | t,
			'summary': 'blog.example_summary' | t,
			'thumbnail': ('images/placeholders/posts/post-' ~ placeholder_num ~ '.webp') | static_url
		}]) %}
	{% endfor %}
{% endif %}

{% if posts | length > 0 %}
	<div class="grid grid-1 grid-md-{{ columns_desktop }} w-100" style="gap: {{ block_gap }}px;">
		{% for post in posts | slice(0, posts_count) %}
			{% include 'snippets/blog/blog-post-item.tpl' %}
		{% endfor %}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.blog_posts",
  "icon": "ListIcon",
  "static": true,
  "settings": [
    {
      "type": "setting",
      "setting_type": "range",
      "id": "posts_count",
      "label": "t:settings.posts_count",
      "min": 1,
      "max": 8,
      "step": 1,
      "default": 3
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns_desktop",
      "label": "t:settings.columns_desktop",
      "icon": "DesktopIcon",
      "options": [
        { "value": "3", "label": "t:options.columns_3" },
        { "value": "4", "label": "t:options.columns_4" }
      ],
      "default": "3"
    },
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
      "default": 16,
      "icon": "horizontal_spacing"
    }
  ]
}
{% endschema %}
