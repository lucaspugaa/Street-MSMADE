{# Image with Text Block - Private to image-with-text section #}

{% set item = block.settings %}

{# Block spacing #}
{% set block_gap = item.gap | default(0) %}

{# Determine image position from block order #}
{# If the image is after the group in the tree, show content on the left (image on the right) in desktop #}
{% set content_before_image = block.blocks | first and block.blocks | first.type != 'image' %}

{# Find image and content blocks #}
{% set image_child = null %}
{% set content_child = null %}
{% for child_block in block.blocks %}
	{% if child_block.type == 'image' %}
		{% set image_child = child_block %}
	{% else %}
		{% set content_child = child_block %}
	{% endif %}
{% endfor %}

<div
	class="media-grid media-grid-md-horizontal {% if content_before_image %}media-grid-content-left{% endif %}"
	{% if block_gap %}style="gap: {{ block_gap }}px;"{% endif %}
	{{ block | block_attributes }}
	data-store="image-with-text-{{ block.id }}"
>
	{# Image column #}
	<div class="media-visual">
		{% if image_child and image_child.settings.image %}
			{% set image_lazy = not is_priority %}
			{% set image_alt = image_child.settings.image | media_alt | default(image_child.settings.alt | default('accessibility.banner' | t)) %}
			{% include 'snippets/image.tpl' with {
				image_src: image_child.settings.image,
				image_alt: image_alt,
				image_classes: 'img-fluid w-100' ~ (image_lazy ? ' fade-in'),
				image_priority_high: is_priority,
				image_lazy_js: image_lazy,
				image_width: image_child.settings.image_width,
				image_height: image_child.settings.image_height,
				image_aspect_ratio: image_child.settings.image_width and image_child.settings.image_height,
			} %}
			{% if image_lazy %}
				<div class="placeholder placeholder-fade"></div>
			{% endif %}
		{% elseif image_child %}
			{# Fallback placeholder only when no image is configured. Cycles image-text-1/2/3.webp by position. #}
			{% set placeholder_num = ((block_index | default(0)) % 3) + 1 %}
			{% set image_lazy = not is_priority %}
			{% include 'snippets/image.tpl' with {
				image_src: ('images/placeholders/image-text/image-text-' ~ placeholder_num ~ '.webp') | static_url,
				image_alt: 'accessibility.banner' | t,
				image_classes: 'img-fluid w-100' ~ (image_lazy ? ' fade-in'),
				image_priority_high: is_priority,
				image_lazy_js: image_lazy,
				image_width: 1280,
				image_height: 700,
				image_aspect_ratio: true,
			} %}
			{% if image_lazy %}
				<div class="placeholder placeholder-fade"></div>
			{% endif %}
		{% endif %}
	</div>

	{# Content column #}
	<div class="media-content-group">
		{% if content_child %}
			{% include 'blocks/text-group.tpl' with { block: content_child } %}
		{% endif %}
	</div>
</div>

{% schema %}
{
  "name": "t:names.image_with_text",
  "icon": "ImageTextIcon",
  "blocks": [
    { "type": "image" },
    { "type": "text-group" }
  ],
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
      "setting_type": "range",
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 0,
      "icon": "vertical_spacing"
    }
  ],
  "presets": [
    {
      "name": "t:names.image_with_text",
      "settings": { "gap": 0 },
      "blocks": [
        { "type": "image" },
        {
          "type": "text-group",
          "settings": { "alignment": "start", "gap": 16, "vertical_padding": 32, "horizontal_padding": 32 },
          "blocks": [
            { "type": "heading", "settings": { "title": "t:defaults.image_with_text.heading", "size": "h4" } },
            { "type": "text", "settings": { "text": "t:defaults.image_with_text.description" } },
            { "type": "button", "settings": { "label": "t:defaults.image_with_text.button", "link": "#", "style": "primary" } }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
