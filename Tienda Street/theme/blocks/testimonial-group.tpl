{# Testimonial Group Block - Container for testimonial items with layout control #}

{% set alignment = block.settings.alignment %}
{% set format = block.settings.format %}
{% set columns = block.settings.columns %}
{% set gap = block.settings.gap %}
{% set avatar_layout = block.settings.avatar_layout %}
{% set image_style = block.settings.image_style %}

{% set content_alignment = alignment %}
{% set item_count = block.blocks | length %}
{% set has_items = item_count > 0 %}

{% set use_slider = format == 'carousel' %}

<div class="testimonial-group text-{{ alignment }}" {{ block | block_attributes }} data-store="testimonial-group-{{ block.id }}">
	{% if has_items %}
		{% if use_slider %}
			<div class="js-testimonials-slider-container testimonials-slider-wrapper" data-columns-desktop="{{ columns }}" data-gap="{{ gap }}" style="--grid-gap: {{ gap }}px">
				<div class="js-testimonials-slider swiper-container">
					<div class="swiper-wrapper">
		{% else %}
			<div class="flex-grid {% if alignment == 'center' %}justify-items-center{% endif %} {% if alignment == 'right' %}justify-items-end{% endif %}"
				style="--cols: 1; --cols-md: {{ columns }}; --grid-gap: {{ gap }}px; row-gap: {{ gap }}px;">
		{% endif %}
						{% for child_block in block.blocks %}
							{% if child_block and child_block.type is defined %}
								{% if use_slider %}
									<div class="swiper-slide">
								{% endif %}
									{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block, avatar_layout: avatar_layout, content_alignment: content_alignment, image_style: image_style } %}
								{% if use_slider %}
									</div>
								{% endif %}
							{% endif %}
						{% endfor %}
		{% if use_slider %}
					</div>
				</div>
				{% if item_count > 1 %}
					<button type="button" class="js-swiper-testimonials-prev swiper-button-prev swiper-button-outside" aria-label="{{ 'general.previous' | t }}">
						<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
					<button type="button" class="js-swiper-testimonials-next swiper-button-next swiper-button-outside" aria-label="{{ 'general.next' | t }}">
						<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
					<div class="js-swiper-testimonials-pagination swiper-testimonials-pagination swiper-pagination swiper-pagination-outside"></div>
				{% endif %}
			</div>
		{% else %}
			</div>
		{% endif %}
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.testimonial_group",
  "icon": "FolderIcon",
  "deletable": false,
  "limit": 1,
  "blocks": [
    { "type": "testimonial", "limit": 6 }
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
      "type": "setting",
      "setting_type": "radio",
      "id": "format",
      "label": "t:settings.format",
      "options": [
        { "value": "grid", "label": "t:options.grid" },
        { "value": "carousel", "label": "t:options.slider" }
      ],
      "default": "grid"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns",
      "label": "t:settings.columns_desktop",
      "icon": "DesktopIcon",
      "options": [
        { "value": "2", "label": "t:options.columns_2" },
        { "value": "3", "label": "t:options.columns_3" }
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
    },
    {
      "type": "header",
      "content": "t:names.image_properties"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "image_style",
      "label": "t:settings.image_shape",
      "options": [
        { "value": "square", "label": "t:options.square" },
        { "value": "rounded", "label": "t:options.rounded" }
      ],
      "default": "rounded"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "avatar_layout",
      "label": "t:settings.image_position",
      "options": [
        { "value": "top", "label": "t:options.above" },
        { "value": "left", "label": "t:options.left" }
      ],
      "default": "top"
    }
  ]
}
{% endschema %}
