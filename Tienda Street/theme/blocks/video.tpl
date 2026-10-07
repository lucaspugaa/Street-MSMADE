{# Video Block - Public, can be used anywhere #}
{# Supports YouTube and Vimeo URLs with autoplay or manual playback #}
{# Accepts is_priority from parent section for LCP optimization #}

{% set video_settings = block.settings %}
{% set video_url = video_settings.video_url %}
{% set video_type = video_settings.video_type | default('autoplay') %}
{% set aspect_ratio = video_settings.aspect_ratio | default('16by9') %}
{% set cover_image = video_settings.show_cover_image ? video_settings.cover_image : null %}
{% set image_alt = video_settings.cover_image | media_alt | default('accessibility.video' | t) %}

{% set video_provider = video_url.type | default('youtube') %}
{% set video_id = video_url.id %}

{# Thumbnail: cover image > provider thumbnail > placeholder (empty section) > null (JS fetches) #}
{% set video_thumb_src = cover_image
	? cover_image
	: (video_url.thumbnail
		? video_url.thumbnail
		: (video_id
			? null
			: 'images/placeholders/video/video.webp' | static_url))
%}

{# Priority: when first section + autoplay, thumbnail only shows on mobile (desktop autoplays directly) #}
{% set is_lazy = not is_priority %}
{% set show_mobile_only = is_priority and video_type == 'autoplay' %}

{# Aspect ratio: the base class is applied on all devices except when ratios vary by device #}
{% set has_mobile_override = video_settings.use_different_mobile_format %}
{% set base_ratio = has_mobile_override ? video_settings.format_mobile : aspect_ratio %}
{% set desktop_ratio = has_mobile_override ? aspect_ratio : false %}

<div
	class="js-video-block video-block"
	{{ block | block_attributes }}
	data-store="video-block-{{ block.id }}"
	data-video-id="{{ video_id }}"
	data-video-type="{{ video_type }}"
	data-video-provider="{{ video_provider }}"
	data-priority="{{ is_priority ? 'true' : 'false' }}"
>
	<div class="embed-responsive embed-responsive-{{ base_ratio }} {% if desktop_ratio %}embed-responsive-desktop-{{ desktop_ratio }}{% endif %} {% if video_id and video_type == 'autoplay' %}video-block-autoplay{% endif %} position-relative">
		{# Play/pause buttons for manual mode #}
		{% if video_id and video_type == 'manual' %}
			<a href="#" class="js-video-play-button video-player video-block-overlay" aria-label="{{ 'general.play' | t }}">
				<div class="video-player-icon">
					<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
				</div>
			</a>
			<a href="#" class="js-video-pause-button video-player video-block-overlay" style="display:none" aria-label="{{ 'general.pause' | t }}">
				<div class="video-player-icon">
					<svg class="video-play-icon icon-inline"><use xlink:href="#pause"/></svg>
				</div>
			</a>
		{% endif %}

		<div class="js-video-thumbnail video-block-thumbnail {% if video_id and video_type == 'autoplay' %}video-block-thumbnail-autoplay{% endif %} {% if video_id and show_mobile_only %}d-block d-md-none{% endif %}" {% if not video_thumb_src %}style="display:none"{% endif %}>
			{% include 'snippets/image.tpl' with {
				image_src: video_thumb_src,
				image_alt: image_alt,
				image_lazy_js: is_lazy,
				image_priority_high: is_priority,
				image_classes: 'video-block-image' ~ (is_lazy ? ' fade-in'),
				image_thumbs: (cover_image or not video_id) ? null : false,
			} %}
			<div class="placeholder {% if video_id and video_type == 'autoplay' %}placeholder-shine{% else %}placeholder-fade{% endif %}"></div>
		</div>

		{% if video_id %}
			{# Video iframe container - will be populated by JS #}
			<div class="js-video-iframe video-block-iframe"></div>

			{# Overlay to hide native controls — autoplay always, manual for Vimeo (custom buttons used instead) #}
			{% if video_type == 'autoplay' or (video_type == 'manual' and video_provider == 'vimeo') %}
				<div class="video-block-hide-controls"></div>
			{% endif %}
		{% endif %}
	</div>
</div>

{% schema %}
{
  "name": "t:names.video",
  "icon": "PlayIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "video_url",
      "id": "video_url",
      "label": "t:settings.video_url",
      "icon": "VideoIcon",
      "info": "t:info.video_url"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_cover_image",
      "label": "t:settings.video_cover_image",
      "info": "t:info.video_cover_image",
      "default": true,
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "cover_image",
      "label": "t:settings.image",
      "visible_if": "{{ block.settings.show_cover_image }}"
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
      "id": "aspect_ratio",
      "label": "t:settings.format",
      "options": [
        { "value": "16by9", "label": "t:options.aspect_panoramic" },
        { "value": "4by3", "label": "t:options.aspect_horizontal" },
        { "value": "1by1", "label": "t:options.aspect_square" }
      ],
      "default": "16by9"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_format",
      "label": "t:settings.use_different_mobile_format",
      "default": false
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
      "default": "16by9",
      "visible_if": "{{ block.settings.use_different_mobile_format }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.video",
      "category": "t:categories.media"
    }
  ]
}
{% endschema %}
