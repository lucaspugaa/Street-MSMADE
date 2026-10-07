{# Newsletter Section - Image with newsletter content #}

{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
{% set theme_settings = settings %}
{% set settings = section.settings %}

{# Data store for backward compatibility #}
{% set data_store_value = claim_legacy_data_store('home-newsletter') ? 'home-newsletter' : section.id %}

{# Image position #}
{% set image_position = settings.image_position | default('background') %}
{% set background_layout = image_position == 'background' %}

{# Images #}
{% set has_mobile_image = settings.use_mobile_image and settings.image_mobile %}
{% set has_responsive_images = settings.image and has_mobile_image %}
{% set image_alt = settings.image | media_alt | default('accessibility.newsletter' | t) %}
{% set image_mobile_alt = settings.image_mobile | media_alt | default('accessibility.newsletter' | t) %}

{# Width #}
{% set page_width = settings.section_width == 'page' %}

{# Alignment #}
{% set text_alignment = settings.text_alignment | default('center') %}

{# Colors #}
{% set background_color = settings.background_color %}
{% set text_color = settings.text_color %}

{# Spacing #}
{% set horizontal_gap = settings.horizontal_gap | default(16) %}
{% set vertical_gap = settings.vertical_gap | default(32) %}
{% set vertical_padding = settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (settings.horizontal_padding | default(32)) %}

{# Overlay (background layout only) #}
{% set show_overlay = settings.show_overlay %}
{% set overlay_color = settings.overlay_color | default('#000000') %}
{% set overlay_opacity = show_overlay ? ((settings.overlay_opacity | default(30)) / 100) : 0 %}


<div
	class="newsletter-section {% if background_layout and settings.image %}media media-auto media-full-width section-full-width{% elseif background_layout and not page_width %}section-full-width{% endif %}"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	style="{% if background_color %}background-color: {{ background_color }};{% endif %} {% if text_color %}color: {{ text_color }};{% endif %} {% if background_layout and show_overlay %}--media-overlay-color: {{ overlay_color }}; --media-overlay-opacity: {{ overlay_opacity }};{% endif %}"
>
	{% if background_layout %}
		{# Background layout: image as background, content overlays #}
		{% if settings.image %}
			<div class="media-visual">
				{# Desktop image #}
				{% set desktop_lazy = has_responsive_images or not is_priority_section %}
				{% include 'snippets/image.tpl' with {
					image_src: settings.image,
					image_alt: image_alt,
					image_classes: (has_responsive_images ? 'd-none d-md-block ') ~ (desktop_lazy ? 'fade-in'),
					image_priority_high: not has_responsive_images and is_priority_section,
					image_lazy_js: desktop_lazy,
					image_width: settings.image_width,
					image_height: settings.image_height,
					image_aspect_ratio: settings.image_width and settings.image_height,
				} %}
				{% if desktop_lazy %}
					<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-none d-md-block' }}"></div>
				{% endif %}

				{# Mobile image #}
				{% if has_mobile_image %}
					{% include 'snippets/image.tpl' with {
						image_src: settings.image_mobile,
						image_alt: image_mobile_alt,
						image_classes: (has_responsive_images ? 'd-md-none ') ~ (not is_priority_section ? 'fade-in'),
						image_priority_high: is_priority_section,
						image_lazy_js: not is_priority_section,
						image_width: settings.image_mobile_width,
						image_height: settings.image_mobile_height,
						image_aspect_ratio: settings.image_mobile_width and settings.image_mobile_height,
					} %}
					{% if not is_priority_section %}
						<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-md-none' }}"></div>
					{% endif %}
				{% endif %}

				{# Overlay #}
				{% if show_overlay %}
					<div class="media-overlay"></div>
				{% endif %}
			</div>
		{% endif %}

		{# Content #}
		<div class="media-content {% if settings.image %}media-content-floating{% endif %} media-content-center text-{{ text_alignment }} newsletter-align-{{ text_alignment }}{% if page_width %} container{% endif %}" style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px; gap: {{ horizontal_gap }}px;">
			{% for block in section.blocks %}
				{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block, settings: theme_settings } %}
			{% endfor %}
		</div>
	{% else %}
		{# Horizontal layout: image left or right with content #}
		{% set content_left = image_position == 'right' %}

		{% if page_width %}
			<div class="container">
		{% endif %}
			<div
				class="media-grid media-grid-md-horizontal {% if content_left %}media-grid-content-left{% endif %}"
				style="gap: {{ vertical_gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
			>
				{# Image column #}
				<div class="media-visual">
					{% if settings.image %}
						{% set image_lazy = not is_priority_section %}
						{% include 'snippets/image.tpl' with {
							image_src: settings.image,
							image_alt: image_alt,
							image_classes: 'img-fluid w-100' ~ (image_lazy ? ' fade-in'),
							image_priority_high: is_priority_section,
							image_lazy_js: image_lazy,
							image_width: settings.image_width,
							image_height: settings.image_height,
							image_aspect_ratio: settings.image_width and settings.image_height,
						} %}
						{% if image_lazy %}
							<div class="placeholder placeholder-fade"></div>
						{% endif %}
					{% endif %}
				</div>

				{# Content column #}
				<div class="media-content media-content-newsletter text-{{ text_alignment }} newsletter-align-{{ text_alignment }}" style="gap: {{ horizontal_gap }}px;">
					{% for block in section.blocks %}
						{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block, settings: theme_settings } %}
					{% endfor %}
				</div>
			</div>
		{% if page_width %}
			</div>
		{% endif %}
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.newsletter",
  "add_section_order": 14,
  "class": "section section-newsletter",
  "blocks": [
    { "tags": ["general"] }
  ],
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:settings.image"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_mobile_image",
      "label": "t:settings.use_mobile_image",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image_mobile",
      "label": "t:settings.image_mobile",
      "visible_if": "{{ section.settings.use_mobile_image }}"
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "image_position",
      "label": "t:settings.image_position",
      "options": [
        { "value": "background", "label": "t:options.background" },
        { "value": "left", "label": "t:options.left" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "background"
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
      "default_setting": "background_color"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text_color",
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
      "id": "vertical_gap",
      "label": "t:settings.vertical_gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_spacing",
      "visible_if": "{{ section.settings.image_position != 'background' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_gap",
      "label": "t:settings.horizontal_gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
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
      "content": "t:content.background",
      "visible_if": "{{ section.settings.image_position == 'background' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_overlay",
      "label": "t:settings.add_overlay",
      "default": false,
      "visible_if": "{{ section.settings.image_position == 'background' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "overlay_color",
      "label": "t:settings.color",
      "default": "#000000",
      "visible_if": "{{ section.settings.image_position == 'background' }}",
      "disabled_if": "{{ section.settings.show_overlay == false }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "overlay_opacity",
      "label": "t:settings.overlay_opacity",
      "min": 0,
      "max": 100,
      "step": 5,
      "unit": "%",
      "default": 30,
      "visible_if": "{{ section.settings.image_position == 'background' }}",
      "disabled_if": "{{ section.settings.show_overlay == false }}"
    }
  ],
  "enabled_on": {
    "page_templates": "all",
    "layout_templates": ["footer"]
  },
  "presets": [
    {
      "name": "t:names.newsletter",
      "category": "t:categories.content",
      "settings": {
        "image_position": "background",
        "text_alignment": "center",
        "section_width": "page",
        "horizontal_gap": 16,
        "vertical_gap": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.newsletter.heading",
            "size": "h4"
          }
        },
        {
          "type": "text",
          "settings": {
            "text": "t:defaults.newsletter.description"
          }
        },
        {
          "type": "newsletter-form"
        }
      ]
    }
  ]
}
{% endschema %}
