{# Banner Block - Private to banners section #}

{% set banner = block.settings %}
{% set has_link = banner.link %}

{# Layout #}
{% set text_outside = banner.text_outside %}
{% set text_over_image = not text_outside %}

{# Alignment → position classes for overlay mode #}
{% set horizontal_align = banner.alignment | default('start') %}
{% set vertical_align = banner.alignment_vertical | default('bottom') %}
{% set horizontal_align_class = horizontal_align == 'start' ? 'left' : (horizontal_align == 'end' ? 'right' : 'center') %}
{% set vertical_align_class = vertical_align %}

{% if vertical_align_class == 'center' and horizontal_align_class == 'center' %}
	{% set content_position_class = 'media-content-center' %}
{% else %}
	{% set content_position_class = 'media-content-' ~ vertical_align_class ~ '-' ~ horizontal_align_class %}
{% endif %}

{# Text alignment class for text-outside mode #}
{% set text_alignment_class = 'media-content-align-' ~ horizontal_align_class %}

{# Text color #}
{% set text_color = banner.text_color %}

{# Overlay #}
{% set show_overlay = banner.show_overlay %}
{% set overlay_color = banner.overlay_color | default('#000000') %}
{% set overlay_opacity = show_overlay ? ((banner.overlay_opacity | default(30)) / 100) : 0 %}

{# Block-level spacing #}
{% set block_gap = banner.gap | default(16) %}
{% set block_vertical_padding = banner.vertical_padding | default(32) %}
{% set block_horizontal_padding = banner.horizontal_padding | default(32) %}

{# Aspect ratio: forces a fixed crop on the banner image unless 'original' #}
{% set is_forced_aspect = (banner_aspect_ratio | default('original')) != 'original' %}
{% set aspect_padding = banner_aspect_ratio == 'custom' ? (banner_aspect_ratio_height | default(100)) : null %}
{% set aspect_ratio_mobile = banner_aspect_ratio_mobile is not null ? banner_aspect_ratio_mobile : banner_aspect_ratio %}
{% set is_forced_aspect_mobile = aspect_ratio_mobile != 'original' %}
{% set aspect_padding_mobile = aspect_ratio_mobile == 'custom' ? ((banner_aspect_ratio_mobile is not null ? banner_aspect_ratio_mobile_height : banner_aspect_ratio_height) | default(100)) : null %}

{% set mobile_differs = aspect_ratio_mobile != banner_aspect_ratio or aspect_padding_mobile != aspect_padding %}

{# Build crop classes independently for mobile and desktop #}
{% set crop_class = is_forced_aspect_mobile ? 'banner-image-container-cropped banner-image-container-cropped-' ~ aspect_ratio_mobile : '' %}
{% if is_forced_aspect and mobile_differs %}
	{% set crop_class = crop_class ~ ' banner-image-container-cropped-md banner-image-container-cropped-md-' ~ banner_aspect_ratio %}
{% elseif is_forced_aspect_mobile and not is_forced_aspect %}
	{% set crop_class = crop_class ~ ' banner-image-container-original-md' %}
{% endif %}

{# CSS variables for 'custom' ratios: predefined ratios (square/horizontal/vertical) use hardcoded class values,
   but 'custom' needs the user-defined percentage passed as a variable read by the CSS class #}
{% set aspect_style = is_forced_aspect_mobile and aspect_ratio_mobile == 'custom' ? '--aspect-padding: ' ~ aspect_padding_mobile ~ '%;' : '' %}
{% if is_forced_aspect and mobile_differs and banner_aspect_ratio == 'custom' %}
	{% set aspect_style = aspect_style ~ '--aspect-padding-md: ' ~ aspect_padding ~ '%;' %}
{% endif %}

{# Base class: media when text overlays image #}
{% set base_class = text_over_image and not is_forced_aspect ? 'media media-auto' %}

{% set has_image = banner.image or banner.image_mobile %}
{% set show_placeholder = not has_image %}

{% set has_responsive_images = banner.image and banner.image_mobile %}
{% set image_alt = banner.image | media_alt | default('accessibility.banner' | t) %}
{% set image_mobile_alt = banner.image_mobile | media_alt | default('accessibility.banner' | t) %}

<div 
	class="{{ base_class }} banner-block position-relative"
	{{ block | block_attributes }}
	data-store="banner-{{ block.id }}"
	style="{% if show_overlay %}--media-overlay-color: {{ overlay_color }}; --media-overlay-opacity: {{ overlay_opacity }};{% endif %} --banner-gap: {{ block_gap }}px; --banner-vpadding: {{ block_vertical_padding }}px; --banner-hpadding: {{ block_horizontal_padding }}px; {% if text_color %}color: {{ text_color }};{% endif %}"
>
	{# Background Image #}
	<div class="{% if text_over_image %}media-visual{% endif %} banner-image-container {{ crop_class }}" {% if aspect_style %}style="{{ aspect_style }}"{% endif %}>
		{# Desktop image: always lazy when mobile variant exists, otherwise follows priority #}
		{% if banner.image %}
			{% set desktop_lazy = has_responsive_images or not is_priority %}
			{% include 'snippets/image.tpl' with {
				image_src: banner.image,
				image_alt: image_alt,
				image_classes: (has_responsive_images ? 'd-none d-md-block ') ~ 'img-fluid' ~ (desktop_lazy ? ' fade-in'),
				image_priority_high: not has_responsive_images and is_priority,
				image_lazy_js: desktop_lazy,
				image_width: banner.image_width,
				image_height: banner.image_height,
				image_aspect_ratio: banner.image_width and banner.image_height,
			} %}
			{% if desktop_lazy %}
				<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-none d-md-block' }}"></div>
			{% endif %}
		{% elseif show_placeholder %}
			{# Fallback placeholder only when no image is configured at all. Cycles banner-1..6.webp by position. #}
			{% set placeholder_num = ((block_index | default(0)) % 6) + 1 %}
			{% set desktop_lazy = not is_priority %}
			{% include 'snippets/image.tpl' with {
				image_src: ('images/placeholders/banners/banner-' ~ placeholder_num ~ '.webp') | static_url,
				image_alt: 'accessibility.banner' | t,
				image_classes: 'img-fluid' ~ (desktop_lazy ? ' fade-in'),
				image_priority_high: is_priority,
				image_lazy_js: desktop_lazy,
				image_thumbs: false,
				image_width: 1000,
				image_height: 1000,
				image_aspect_ratio: true,
			} %}
			{% if desktop_lazy %}
				<div class="placeholder placeholder-fade"></div>
			{% endif %}
		{% endif %}
		{# Mobile image: prioritized for LCP on first banner of first section #}
		{% if banner.image_mobile %}
			{% include 'snippets/image.tpl' with {
				image_src: banner.image_mobile,
				image_alt: image_mobile_alt,
				image_classes: (has_responsive_images ? 'd-md-none ') ~ 'img-fluid' ~ (not is_priority ? ' fade-in'),
				image_priority_high: is_priority,
				image_lazy_js: not is_priority,
				image_width: banner.image_mobile_width,
				image_height: banner.image_mobile_height,
				image_aspect_ratio: banner.image_mobile_width and banner.image_mobile_height,
			} %}
			{% if not is_priority %}
				<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-md-none' }}"></div>
			{% endif %}
		{% endif %}
		
		{# Overlay #}
		{% if show_overlay and text_over_image %}
			<div class="media-overlay"></div>
		{% endif %}
	</div>
	
	{# Banner link as overlay #}
	{% if has_link %}
		<a href="{{ banner.link }}" class="{% if text_outside %}banner-link-overlay{% else %}media-link{% endif %}" aria-label="{{ 'general.banner' | t }}"></a>
	{% endif %}
	
	{# Content - Renders sub-blocks #}
	{% if block.blocks | length > 0 %}
		<div class="media-content {% if text_outside %}{{ text_alignment_class }}{% else %}media-content-floating {{ content_position_class }}{% endif %} {% if has_link %}media-content-linked{% endif %}" style="gap: {{ block_gap }}px; padding: {{ block_vertical_padding }}px {{ block_horizontal_padding }}px;">
			{% for child_block in block.blocks %}
				{% if child_block and child_block.type is defined %}
					{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
				{% endif %}
			{% endfor %}
		</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.banner",
  "icon": "pictureIcon",
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
      "visible_if": "{{ block.settings.use_mobile_image }}"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.link"
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
      "default": "start",
      "vertical_options": [
        { "value": "top", "label": "t:options.top" },
        { "value": "center", "label": "t:options.center" },
        { "value": "bottom", "label": "t:options.bottom" }
      ],
      "vertical_default": "bottom",
      "vertical_disabled_if": "{{ block.settings.text_outside }}"
    },
    {
      "type": "setting",
      "setting_type": "checkbox",
      "id": "text_outside",
      "label": "t:settings.text_outside",
      "default": false
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
      "default": 32,
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
      "icon": "horizontal_padding"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_overlay",
      "label": "t:names.transparent_background",
      "default": false,
      "info": "t:settings.add_overlay",
      "header_toggle": true,
      "visible_if": "{{ block.settings.text_outside == false }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "overlay_color",
      "label": "t:settings.color",
      "default": "#000000",
      "visible_if": "{{ block.settings.show_overlay }}"
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
      "visible_if": "{{ block.settings.show_overlay }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.banner",
      "settings": { "gap": 16, "vertical_padding": 32, "horizontal_padding": 32 },
      "blocks": [
        { "type": "heading", "settings": { "title": "t:defaults.banner.heading", "size": "h4" } },
        { "type": "text", "settings": { "text": "t:defaults.banner.description" } },
        { "type": "button", "settings": { "label": "t:defaults.banner.button" } }
      ]
    }
  ]
}
{% endschema %}
