{#
  Featured Categories Section
  Displays categories as text pills or image thumbnails in a flexible layout.
#}

{# Data store for backward compatibility #}
{% set data_store_value = claim_legacy_data_store('home-categories-featured') ? 'home-categories-featured' : section.id %}

{# Orientation #}
{% set orientation = section.settings.orientation | default('horizontal') %}
{% set use_different_mobile_orientation = section.settings.use_different_mobile_orientation %}
{% set orientation_mobile = use_different_mobile_orientation ? (section.settings.orientation_mobile | default('horizontal')) : orientation %}

{# Alignment #}
{% set text_alignment = section.settings.text_alignment | default('left') %}

{# Width #}
{% set page_width = section.settings.section_width == 'page' %}
{% set full_width = section.settings.section_width == 'full' %}

{# Spacing #}
{% set gap = section.settings.gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (section.settings.horizontal_padding | default(32)) %}

{# Colors #}
{% set background_color = section.settings.background_color %}

{# Collect blocks - extract category items from nav group children #}
{% set nav_block = null %}
{% set category_blocks = [] %}
{% for block in section.blocks %}
	{% if block.type == 'category-nav' %}
		{% set nav_block = block %}
		{% for child_block in block.blocks %}
			{% if child_block and child_block.type == 'category-item' %}
				{% set category_blocks = category_blocks | merge([child_block]) %}
			{% endif %}
		{% endfor %}
	{% endif %}
{% endfor %}
{% set has_categories = (category_blocks | length) > 0 %}

{# Nav block settings #}
{% set nav_settings = nav_block ? nav_block.settings : {} %}
{% set category_type = nav_settings.category_type | default('text_pill') %}
{% set is_text_pill = category_type == 'text_pill' %}
{% set is_image_thumbnail = category_type == 'image_thumbnail' %}
{% set format_text = nav_settings.format_text | default('rounded') %}
{% set format_image = nav_settings.format_image | default('circular') %}
{% set pill_background_color = nav_settings.background_color %}
{% set pill_text_color = nav_settings.text_color %}
{% set pill_border_color = nav_settings.border_color %}
{% set image_position = nav_settings.image_position | default('left') %}
{% set image_size = nav_settings.image_size | default(80) %}
{% set items_text_alignment = image_position == 'top' ? nav_settings.items_text_alignment | default('left') : 'left' %}
{% set image_border_color = nav_settings.image_border_color | default('currentColor') %}
{% set thumbnail_text_color = nav_settings.text_color | default('currentColor') %}
{% set items_gap = nav_settings.gap | default(16) %}

{# Orientation classes for outer container (heading + categories) #}
{% set mobile_direction = orientation_mobile == 'vertical' ? 'flex-column' : 'flex-row align-items-center' %}
{% set desktop_direction = orientation == 'vertical' ? 'flex-md-column align-items-md-stretch' : 'flex-md-row align-items-md-center' %}

{# Alignment classes #}
{% set flex_align = text_alignment == 'center' ? 'center' : (text_alignment == 'right' ? 'end' : 'start') %}

{# Center slides only when alignment is center #}
{% set center_slides = text_alignment == 'center' %}

{# Type and format modifier classes #}
{% set type_class = is_text_pill ? 'category-list-pill' : 'category-list-thumbnail' %}
{% if is_text_pill %}
	{% set format_class = format_text == 'rounded' ? 'category-pill-rounded' %}
{% else %}
	{% set format_class = format_image == 'circular' ? 'category-image-circular' %}
{% endif %}
{% set position_class = is_image_thumbnail ? 'category-thumbnail-' ~ image_position %}

{# Custom styles #}
{% set custom_styles %}
	--carousel-section-edge: {{ page_width ? 'var(--gutter-container)' : horizontal_padding ~ 'px' }};
	{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
	{% if is_text_pill %}
		{% if pill_background_color %}--category-bg-color: {{ pill_background_color }};{% endif %}
		{% if pill_text_color %}--category-text-color: {{ pill_text_color }};{% endif %}
		--category-border-color: {{ pill_border_color | default('currentColor') }};
	{% endif %}
	{% if is_image_thumbnail %}
		{% if thumbnail_text_color %}--category-text-color: {{ thumbnail_text_color }};{% endif %}
		--category-image-size: {{ image_size }}px;
		{% if image_border_color %}--category-image-border-color: {{ image_border_color }};{% endif %}
	{% endif %}
{% endset %}


<div
	class="js-carousel-section carousel-section-edge featured-categories-section {% if not page_width %}section-full-width{% endif %}"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if custom_styles | trim %}style="{{ custom_styles }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
	<div class="d-flex {{ mobile_direction }} {{ desktop_direction }}" style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px; gap: {{ gap }}px;">

		{# Heading #}
		{% for block in section.blocks %}
			{% if block.type == 'heading' %}
				<div class="text-{{ text_alignment }} flex-shrink-0 {% if orientation == 'horizontal' %}heading-column {% if gap < 32 %}heading-column-safe-spacing{% endif %}{% endif %}">
					{% include 'blocks/heading.tpl' with { block: block } %}
				</div>
			{% endif %}
		{% endfor %}

		{# Category carousel #}
		{% if has_categories %}
			<div class="{{ type_class }} {{ format_class }} {{ position_class }} flex-grow-1 position-relative" style="min-width: 0;" {% if nav_block %}{{ nav_block | block_attributes }}{% endif %}>
				<div class="js-carousel-slider swiper overflow-hidden {% if center_slides %}swiper-center-slides{% endif %}"
					data-columns-mode="auto"
					data-slide-gap="{{ items_gap }}"
					data-center-slides="{{ center_slides ? 'true' : 'false' }}"
					style="--slide-gap: {{ items_gap }}px;">
					<div class="swiper-wrapper">
						{% for cat_block in category_blocks %}
							<div class="swiper-slide w-auto">
								{% include 'blocks/category-item.tpl' with {
									block: cat_block,
									is_image_thumbnail: is_image_thumbnail,
									image_size: image_size,
									category_index: loop.index0,
									items_text_alignment: items_text_alignment,
								} %}
							</div>
						{% endfor %}
					</div>
				</div>

				{# Navigation arrows #}
				{% if (category_blocks | length) > 1 %}
					<button type="button" class="js-carousel-prev swiper-button-prev swiper-button-outside" aria-label="{{ 'general.previous' | t }}">
						<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
					<button type="button" class="js-carousel-next swiper-button-next swiper-button-outside" aria-label="{{ 'general.next' | t }}">
						<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
				{% endif %}
			</div>
		{% endif %}

	</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.featured_categories",
  "icon": "CarouselIcon",
  "add_section_order": 6,
  "class": "section section-featured-categories",
  "max_blocks": 20,
  "blocks": [],
  "locked_blocks": {
    "reorderable": true
  },
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "orientation",
      "label": "t:settings.orientation",
      "options": [
        { "value": "vertical", "label": "t:options.vertical", "icon": "ArrowDownIcon" },
        { "value": "horizontal", "label": "t:options.horizontal", "icon": "ArrowRightIcon" }
      ],
      "default": "horizontal"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_orientation",
      "label": "t:settings.use_different_mobile_orientation",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "orientation_mobile",
      "label": "t:settings.orientation",
      "options": [
        { "value": "vertical", "label": "t:options.vertical", "icon": "ArrowDownIcon" },
        { "value": "horizontal", "label": "t:options.horizontal", "icon": "ArrowRightIcon" }
      ],
      "default": "horizontal",
      "visible_if": "{{ section.settings.use_different_mobile_orientation }}"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "text_alignment",
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
      "max": 100,
      "step": 4,
      "unit": "px",
      "default": 64,
      "icon": "vertical_spacing"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 100,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_spacing",
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
      "name": "t:names.featured_categories",
      "category": "t:categories.content",
      "settings": {
        "orientation": "horizontal",
        "use_different_mobile_orientation": true,
        "orientation_mobile": "vertical",
        "section_width": "page",
        "gap": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.featured_categories.heading",
            "size": "h4"
          }
        },
        {
          "type": "category-nav",
          "static": true,
          "settings": {
            "category_type": "image_thumbnail",
            "format_image": "square",
            "gap": 32
          },
          "blocks": [
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.featured_categories",
      "category": "t:categories.content",
      "settings": {
        "orientation": "vertical",
        "text_alignment": "center",
        "section_width": "page",
        "gap": 32,
        "vertical_padding": 64
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.featured_categories.heading",
            "size": "h5"
          }
        },
        {
          "type": "category-nav",
          "static": true,
          "settings": {
            "category_type": "text_pill",
            "format_text": "rounded",
            "gap": 24
          },
          "blocks": [
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.featured_categories",
      "category": "t:categories.content",
      "settings": {
        "orientation": "vertical",
        "text_alignment": "left",
        "section_width": "page",
        "gap": 32,
        "vertical_padding": 64
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.featured_categories.heading",
            "size": "h4"
          }
        },
        {
          "type": "category-nav",
          "static": true,
          "settings": {
            "category_type": "image_thumbnail",
            "format_image": "square",
            "image_position": "top",
            "items_text_alignment": "left",
            "image_size": 120,
            "gap": 24
          },
          "blocks": [
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } }
          ]
        }
      ]
    },
    {
      "name": "t:names.featured_categories",
      "category": "t:categories.content",
      "settings": {
        "orientation": "vertical",
        "text_alignment": "center",
        "section_width": "page",
        "vertical_padding": 64
      },
      "blocks": [
        {
          "type": "category-nav",
          "static": true,
          "settings": {
            "category_type": "image_thumbnail",
            "format_image": "circular",
            "image_position": "top",
            "items_text_alignment": "center",
            "image_size": 80,
            "gap": 36
          },
          "blocks": [
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } },
            { "type": "category-item", "settings": { "text": "t:defaults.featured_categories.category_text" } }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
