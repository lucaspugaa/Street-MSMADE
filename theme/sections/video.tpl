{# Video Section - Video as background with content floating on top #}
{# Video URL and type are section-level settings (no video block needed) #}

{% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
{% set theme_settings = settings %}
{% set settings = section.settings %}

{# Data store for backward compatibility #}
{% set data_store_value = section.id %}

{# Alignment #}
{% set horizontal_align = settings.alignment | default('center') %}
{% set vertical_align = settings.alignment_vertical | default('center') %}
{% set horizontal_align_class = horizontal_align == 'start' ? 'left' : (horizontal_align == 'end' ? 'right' : 'center') %}
{% set vertical_align_class = vertical_align %}

{% if vertical_align_class == 'center' and horizontal_align_class == 'center' %}
	{% set content_position_class = 'media-content-center' %}
{% else %}
	{% set content_position_class = 'media-content-' ~ vertical_align_class ~ '-' ~ horizontal_align_class %}
{% endif %}

{# Spacing #}
{% set gap = settings.gap | default(16) %}
{% set vertical_padding = settings.vertical_padding | default(0) %}
{% set horizontal_padding = settings.horizontal_padding | default(0) %}

{# Colors #}
{% set text_color = settings.text_color %}

{# Overlay #}
{% set show_overlay = settings.show_overlay %}
{% set overlay_color = settings.overlay_color | default('#000000') %}
{% set overlay_opacity = show_overlay ? ((settings.overlay_opacity | default(30)) / 100) : 0 %}

{% set video_url = settings.video_url %}
{% set video_type = settings.video_type | default('autoplay') %}
{% set video_provider = video_url.type | default('youtube') %}
{% set video_id = video_url.id %}

{# Aspect ratio: the base class is applied on all devices except when ratios vary by device #}
{% set base_ratio = settings.format_mobile | default('16by9') %}
{% set desktop_ratio = base_ratio != '16by9' ? '16by9' : false %}

{% set cover_image = settings.cover_image %}
{# Thumbnail: cover image > provider thumbnail > placeholder (empty section) > null (JS fetches) #}
{% set video_thumb_src = cover_image
	? cover_image
	: (video_url.thumbnail
		? video_url.thumbnail
		: (video_id
			? null
			: 'images/placeholders/video/video.webp' | static_url))
%}
{% set image_alt = settings.cover_image | media_alt | default('accessibility.video' | t) %}

<div
	class="js-video-section media media-full-width section-full-width video-section video-section-background"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	style="{% if show_overlay %}--media-overlay-color: {{ overlay_color }}; --media-overlay-opacity: {{ overlay_opacity }};{% endif %} {% if text_color %}color: {{ text_color }};{% endif %}"
>
	{# Video #}
	{% if video_id %}
		<div class="media-visual">
			<div
				class="js-video-block video-block"
				data-store="video-block-{{ section.id }}"
				data-video-id="{{ video_id }}"
				data-video-type="{{ video_type }}"
				data-video-provider="{{ video_provider }}"
				data-priority="{{ is_priority_section ? 'true' : 'false' }}"
			>
				<div class="embed-responsive embed-responsive-{{ base_ratio }} {% if desktop_ratio %}embed-responsive-desktop-{{ desktop_ratio }}{% endif %} {% if video_type == 'autoplay' %}video-block-autoplay{% endif %} position-relative">
					<div class="js-video-thumbnail video-block-thumbnail {% if video_type == 'autoplay' %}video-block-thumbnail-autoplay{% endif %}" {% if not video_thumb_src %}style="display:none"{% endif %}>
						{% include 'snippets/image.tpl' with {
							image_src: video_thumb_src,
							image_alt: image_alt,
							image_lazy_js: not is_priority_section,
							image_priority_high: is_priority_section,
							image_classes: 'video-block-image' ~ (not is_priority_section ? ' fade-in'),
							image_thumbs: not cover_image ? false : null,
						} %}
						<div class="placeholder {% if video_type == 'autoplay' %}placeholder-shine{% else %}placeholder-fade{% endif %}"></div>
					</div>

					{# Video iframe container #}
					<div class="js-video-iframe video-block-iframe"></div>

					{# Overlay to hide native controls — autoplay always, manual for Vimeo (custom buttons used instead) #}
					{% if video_type == 'autoplay' or (video_type == 'manual' and video_provider == 'vimeo') %}
						<div class="video-block-hide-controls"></div>
					{% endif %}
				</div>
			</div>

			{# Overlay #}
			{% if show_overlay %}
				<div class="media-overlay"></div>
			{% endif %}
		</div>
	{% else %}
		<div class="media-visual">
			{% include 'snippets/image.tpl' with {
				image_src: video_thumb_src,
				image_alt: 'accessibility.video' | t,
				image_classes: 'fade-in',
				image_lazy_js: true,
				image_thumbs: cover_image ? null : false,
				image_width: 1280,
				image_height: 700,
				image_aspect_ratio: true,
			} %}
			<div class="placeholder placeholder-fade"></div>
		</div>
	{% endif %}

	{# Play/pause buttons for manual mode - outside media-visual to stay above content layer #}
	{% if video_id and video_type == 'manual' %}
		<a href="#" class="js-video-play-button video-section-play video-player" aria-label="{{ 'general.play' | t }}">
			<div class="video-player-icon">
				<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
			</div>
		</a>
		<a href="#" class="js-video-pause-button video-section-play video-player" style="display:none" aria-label="{{ 'general.pause' | t }}">
			<div class="video-player-icon">
				<svg class="video-play-icon icon-inline"><use xlink:href="#pause"/></svg>
			</div>
		</a>
	{% endif %}

	{# Content #}
	{% if section.blocks %}
		<div class="media-content media-content-floating {{ content_position_class }} {% if settings.link and video_type == 'autoplay' %}media-content-linked{% endif %}" style="gap: {{ gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px;">
			{% for block in section.blocks %}
				{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block, settings: theme_settings } %}
			{% endfor %}
		</div>
	{% endif %}

	{# Full section link #}
	{% if settings.link and video_type == 'autoplay' %}
		<a href="{{ settings.link }}" class="media-link" aria-label="{{ 't:names.video' | t }}"></a>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.video",
  "icon": "VideoIcon",
  "add_section_order": 4,
  "class": "section section-video",
  "blocks": [
    { "tags": ["general"] }
  ],
  "settings": [
    {
      "type": "setting",
      "setting_type": "video_url",
      "id": "video_url",
      "label": "t:settings.video_url",
      "icon": "VideoIcon"
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "cover_image",
      "label": "t:settings.video_cover_image",
      "info": "t:info.video_cover_image"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.link",
      "visible_if": "{{ section.settings.video_type == 'autoplay' }}"
    },
    {
      "type": "header",
      "content": "t:names.video_properties"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "video_type",
      "label": "t:settings.video_type",
      "options": [
        { "value": "autoplay", "label": "t:options.autoplay" },
        { "value": "manual", "label": "t:options.manual" }
      ],
      "default": "autoplay"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "format_mobile",
      "label": "t:settings.format_mobile",
      "options": [
        { "value": "16by9", "label": "t:options.aspect_panoramic" },
        { "value": "4by3", "label": "t:options.aspect_horizontal" },
        { "value": "1by1", "label": "t:options.aspect_square" },
        { "value": "9by16", "label": "t:options.aspect_vertical_portrait" }
      ],
      "default": "16by9"
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "start", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "end", "label": "t:options.right" }
      ],
      "default": "center",
      "vertical_options": [
        { "value": "top", "label": "t:options.top" },
        { "value": "center", "label": "t:options.center" },
        { "value": "bottom", "label": "t:options.bottom" }
      ],
      "vertical_default": "center"
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
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 0,
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
      "icon": "horizontal_padding"
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_overlay",
      "label": "t:names.transparent_background",
      "default": false,
      "info": "t:settings.add_overlay",
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "overlay_color",
      "label": "t:settings.color",
      "default": "#000000",
      "visible_if": "{{ section.settings.show_overlay }}"
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
      "visible_if": "{{ section.settings.show_overlay }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.video",
      "category": "t:categories.media",
      "settings": {
        "gap": 16,
        "vertical_padding": 32,
        "horizontal_padding": 32
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.video.heading",
            "size": "h4"
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
{% endschema %}
