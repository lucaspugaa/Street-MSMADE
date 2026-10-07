{# Instagram Posts Block - Private block for instagram-feed section #}

{% set posts_count = block.settings.posts_count %}
{% set columns = block.settings.columns %}
{% set columns_mobile = block.settings.columns_mobile %}
{% set block_gap = block.settings.gap %}

{% set grid_classes = 'grid grid-' ~ columns_mobile ~ ' grid-md-' ~ columns %}

<div class="block-fill" {{ block | block_attributes }}>
	{% if store.hasInstagramToken() %}
		<div class="js-ig-success {{ grid_classes }}"
			data-ig-feed
			data-ig-items-count="{{ posts_count }}"
			data-ig-link-class="instafeed-link"
			data-ig-image-class="instafeed-img"
			data-ig-aria-label="{{ 'instagram.post_from' | t }} {{ store.name }}"
			style="{% if block_gap %}gap: {{ block_gap }}px;{% endif %}">
		</div>
	{% else %}
		<div class="{{ grid_classes }}" style="{% if block_gap %}gap: {{ block_gap }}px;{% endif %}">
			{% for i in 1..posts_count %}
				{% set placeholder_num = ((i - 1) % 6) + 1 %}
				<div class="instafeed-link" style="padding-top: 0; aspect-ratio: 1 / 1;">
					{% include 'snippets/image.tpl' with {
						image_src: ('images/placeholders/posts/post-' ~ placeholder_num ~ '.webp') | static_url,
						image_alt: 'accessibility.instagram' | t,
						image_classes: 'instafeed-img fade-in',
						image_lazy_js: true,
						image_thumbs: false,
					} %}
				</div>
			{% endfor %}
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.instagram_posts",
  "icon": "LayoutIcon",
  "deletable": false,
  "limit": 1,
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "posts_count",
      "label": "t:settings.posts_count",
      "options": [
        { "value": "4", "label": "4" },
        { "value": "6", "label": "6" },
        { "value": "8", "label": "8" },
        { "value": "10", "label": "10" },
        { "value": "12", "label": "12" }
      ],
      "default": "4"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns",
      "label": "t:settings.columns_desktop",
      "icon": "DesktopIcon",
      "options": [
        { "value": "2", "label": "t:options.columns_2" },
        { "value": "3", "label": "t:options.columns_3" },
        { "value": "4", "label": "t:options.columns_4" }
      ],
      "default": "4"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns_mobile",
      "label": "t:settings.columns_mobile",
      "icon": "MobileIcon",
      "options": [
        { "value": "1", "label": "t:options.columns_1" },
        { "value": "2", "label": "t:options.columns_2" }
      ],
      "default": "2"
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
