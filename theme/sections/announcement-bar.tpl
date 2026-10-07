{# Announcement Bar section #}

{% set has_blocks = (section.blocks | length) > 0 %}
{% set has_multiple_announcements = (section.blocks | length) > 1 %}
{% set animation = section.settings.animation %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}
{% set is_marquee = animation == 'marquee' %}
{% set page_width = not is_marquee and section.settings.section_width == 'page' %}
{% set full_width = is_marquee or section.settings.section_width == 'full' %}
{# Lateral padding only applies in "full" width when marquee mode is not active #}
{% set horizontal_padding = (full_width and not is_marquee) ? section.settings.horizontal_padding : 0 %}

{# Mobile-specific spacing: when toggle is off, mobile inherits the desktop values #}
{% set use_mobile_spacing = section.settings.use_different_mobile_spacing %}
{% set mobile_vertical_padding = use_mobile_spacing ? section.settings.mobile_vertical_padding | default(16) : vertical_padding %}
{% set mobile_horizontal_padding = is_marquee ? 0 : (full_width and use_mobile_spacing ? section.settings.mobile_horizontal_padding | default(20) : horizontal_padding) %}

{# Build inline styles #}
{% set adbar_styles %}
	--adbar-py: {{ vertical_padding }}px;
	--adbar-mobile-py: {{ mobile_vertical_padding }}px;
	--adbar-px: {{ horizontal_padding }}px;
	--adbar-mobile-px: {{ mobile_horizontal_padding }}px;
	background-color: {{ background_color }}; color: {{ text_color }};
{% endset %}

{% if has_blocks %}

	<div class="adbar" data-section-id="{{ section.id }}" data-section-type="announcement-bar" data-store="adbar" style="{{ adbar_styles }}">
		{% if is_marquee %}
			<div class="js-adbar-marquee adbar-marquee" data-speed="{{ section.settings.animation_speed }}" data-direction="left">
				<div class="js-adbar-marquee-content adbar-marquee-content">
		{% else %}
			{% if page_width %}
				<div class="container"{% if horizontal_padding %} style="padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;"{% endif %}>
			{% endif %}
				{% if animation == 'slider' %}
					<div class="js-adbar-slider adbar-slider {% if has_multiple_announcements %}adbar-slider-has-nav{% endif %} swiper-container text-center" data-autoplay="{{ has_multiple_announcements ? 'true' : 'false' }}" data-speed="{{ section.settings.slider_speed }}">
						<div class="swiper-wrapper">
				{% else %}
					<div class="adbar-static d-flex justify-content-center align-items-center text-center">
				{% endif %}
		{% endif %}

					{% for block in section.blocks %}
						{% if block.type == 'announcement' %}
							{% if animation == 'slider' %}
								<div class="js-adbar-slide swiper-slide" {{ block | block_attributes }}>
							{% endif %}
							<div class="{% if is_marquee %}js-adbar-item{% endif %} adbar-item" {% if animation != 'slider' %}{{ block | block_attributes }}{% endif %}>
								{% if block.settings.link %}
									<a href="{{ block.settings.link }}" style="color: inherit;">{{ block.settings.text }}</a>
								{% else %}
									<span>{{ block.settings.text }}</span>
								{% endif %}
							</div>
							{% if animation == 'slider' %}
								</div>
							{% endif %}
						{% endif %}
					{% endfor %}

		{% if is_marquee %}
				</div>
			</div>
		{% elseif animation == 'slider' %}
						</div>
					{% if has_multiple_announcements %}
						<button type="button" class="js-adbar-slider-prev swiper-button-prev" aria-label="{{ 'general.previous' | t }}">
							<svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>
						</button>
						<button type="button" class="js-adbar-slider-next swiper-button-next" aria-label="{{ 'general.next' | t }}">
							<svg viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M8.59 16.59L10 18l6-6-6-6-1.41 1.41L13.17 12z"/></svg>
						</button>
					{% endif %}
				</div>
			{% if page_width %}
				</div>
			{% endif %}
		{% else %}
				</div>
			{% if page_width %}
				</div>
			{% endif %}
		{% endif %}
	</div>

{% endif %}

{% schema %}
{
  "name": "t:names.announcement_bar",
  "icon": "MarketingIcon",
  "class": "section-announcement-bar",
  "limit": 3,
  "blocks": [
    {
      "type": "announcement"
    }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "background_color",
      "label": "t:settings.background",
      "default": "#000000"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default": "#ffffff"
    },
    {
      "type": "header",
      "content": "t:names.animation"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "animation",
      "label": "t:settings.display_mode",
      "options": [
        { "value": "none", "label": "t:options.static" },
        { "value": "slider", "label": "t:options.slider" },
        { "value": "marquee", "label": "t:options.marquee" }
      ],
      "default": "slider"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "animation_speed",
      "label": "t:settings.animation_speed",
      "min": 1,
      "max": 10,
      "step": 1,
      "default": 5,
      "visible_if": "{{ section.settings.animation == 'marquee' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "slider_speed",
      "label": "t:settings.autoplay_speed",
      "min": 1,
      "max": 10,
      "step": 1,
      "unit": "s",
      "default": 5,
      "icon": "ClockIcon",
      "visible_if": "{{ section.settings.animation == 'slider' }}"
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
      "default": "full",
      "visible_if": "{{ section.settings.animation != 'marquee' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 24,
      "step": 2,
      "unit": "px",
      "default": 8,
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
      "visible_if": "{{ section.settings.animation != 'marquee' }}",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_spacing",
      "label": "t:settings.use_different_mobile_padding",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "mobile_vertical_padding",
      "label": "t:settings.vertical_padding_mobile",
      "min": 0,
      "max": 24,
      "step": 2,
      "unit": "px",
      "default": 16,
      "icon": "vertical_padding",
      "visible_if": "{{ section.settings.use_different_mobile_spacing }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "mobile_horizontal_padding",
      "label": "t:settings.horizontal_padding_mobile",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_padding",
      "visible_if": "{{ section.settings.use_different_mobile_spacing and section.settings.animation != 'marquee' }}",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "enabled_on": {
    "layout_templates": ["header"]
  },
  "presets": [
    {
      "name": "t:names.announcement_bar",
      "settings": {
        "background_color": "#000000",
        "text_color": "#ffffff",
        "animation": "slider",
        "section_width": "full",
        "vertical_padding": 8,
        "horizontal_padding": 32,
        "slider_speed": 5
      },
      "blocks": [
        {
          "type": "announcement",
          "settings": {
            "text": "t:defaults.announcements.announcement_1"
          }
        }
      ]
    }
  ]
}
{% endschema %}
