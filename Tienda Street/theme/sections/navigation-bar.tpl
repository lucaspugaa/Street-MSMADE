{# Navigation Bar section — horizontal bar with heterogeneous groups (announcements, menu, institutional, icons) #}

{% set has_blocks = (section.blocks | length) > 0 %}
{% set mobile_placement = section.settings.mobile_placement | default('header') %}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set item_gap = section.settings.item_gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(8) %}
{# Lateral padding only applies in "full" width; "page" relies on .container #}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding | default(32) %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Mobile-specific spacing: when toggle is off, mobile inherits the desktop values #}
{% set use_mobile_spacing = section.settings.use_different_mobile_spacing %}
{% set mobile_vertical_padding = use_mobile_spacing ? section.settings.mobile_vertical_padding | default(16) : vertical_padding %}

{% set mobile_horizontal_padding = use_mobile_spacing ? section.settings.mobile_horizontal_padding | default(20) : horizontal_padding %}

{% set navbar_styles %}
	--navbar-gap: {{ item_gap }}px;
	--navbar-py: {{ vertical_padding }}px;
	--navbar-mobile-py: {{ mobile_vertical_padding }}px;
	{% if full_width %}--navbar-px: {{ horizontal_padding }}px; --navbar-mobile-px: {{ mobile_horizontal_padding }}px;{% endif %}
	{% if background_color %}--navbar-bg: {{ background_color }}; background-color: {{ background_color }};{% endif %}
	{% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}

{% if has_blocks %}

	{# Desktop / mobile-header bar #}
	<div
		class="js-navigation-bar navigation-bar {% if mobile_placement == 'menu' %}d-none d-md-block{% endif %}"
		data-section-id="{{ section.id }}"
		data-section-type="navigation-bar"
		style="{{ navbar_styles }}"
	>
		{% if page_width %}
			<div class="container">
		{% endif %}
				<div class="navigation-bar-inner">
					<button type="button" class="js-navigation-bar-arrow-left nav-desktop-list-arrow nav-desktop-list-arrow-left disable" aria-label="{{ 'general.previous' | t }}" style="display: none">
						<svg class="nav-arrow-icon icon-flip-horizontal icon-inline"><use xlink:href="#chevron"/></svg>
					</button>
					<div class="js-navigation-bar-list navigation-bar-list">
						{% for block in section.blocks %}
							<div class="navigation-bar-group navigation-bar-group-{{ block.type }}">
								{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
							</div>
						{% endfor %}
					</div>
					<button type="button" class="js-navigation-bar-arrow-right nav-desktop-list-arrow nav-desktop-list-arrow-right" aria-label="{{ 'general.next' | t }}" style="display: none">
						<svg class="nav-arrow-icon icon-inline"><use xlink:href="#chevron"/></svg>
					</button>
				</div>
		{% if page_width %}
			</div>
		{% endif %}
	</div>

	{# Pre-rendered mobile version for the hamburger menu. JS moves children to the mount point. #}
	{% if mobile_placement == 'menu' %}
		<div class="js-navigation-bar-mobile" style="display: none;">
			{% for block in section.blocks %}
				<div class="nav-secondary">
					{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block, type: 'mobile_menu' } %}
				</div>
			{% endfor %}
		</div>
	{% endif %}

{% endif %}

{% schema %}
{
  "name": "t:names.navigation_bar",
  "icon": "TabletIcon",
  "class": "section-navigation-bar",
  "limit": 3,
  "max_blocks": 3,
  "blocks": [
    { "type": "nav-announcements", "limit": 2 },
    { "type": "nav-social", "limit": 1 },
    { "type": "nav-contact", "limit": 1 },
    { "type": "nav-menu", "limit": 2 },
    { "type": "nav-icon-text-group", "limit": 2 }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "mobile_placement",
      "label": "t:settings.navbar_mobile_placement",
      "options": [
        { "value": "header", "label": "t:options.navbar_mobile_in_header" },
        { "value": "menu", "label": "t:options.navbar_mobile_in_menu" }
      ],
      "default": "header"
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
      "id": "item_gap",
      "label": "t:settings.navbar_item_gap",
      "min": 0,
      "max": 48,
      "step": 2,
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
      "max": 32,
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
      "max": 32,
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
      "visible_if": "{{ section.settings.use_different_mobile_spacing }}",
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
      "default": "#000000"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default": "#ffffff"
    }
  ],
  "enabled_on": {
    "layout_templates": ["header"]
  },
  "presets": [
    {
      "name": "t:names.navigation_bar",
      "settings": {
        "mobile_placement": "header",
        "section_width": "page",
        "item_gap": 32,
        "vertical_padding": 8,
        "horizontal_padding": 32,
        "background_color": "#000000",
        "text_color": "#ffffff"
      },
      "blocks": [
        {
          "type": "nav-announcements",
          "settings": { "alignment": "left", "gap": 16 },
          "blocks": [
            {
              "type": "announcement",
              "settings": { "text": "t:defaults.announcements.announcement_1" }
            },
            {
              "type": "announcement",
              "settings": { "text": "t:defaults.announcements.announcement_2" }
            }
          ]
        },
        {
          "type": "nav-social",
          "settings": { "alignment": "right", "gap": 16 }
        }
      ]
    }
  ]
}
{% endschema %}
