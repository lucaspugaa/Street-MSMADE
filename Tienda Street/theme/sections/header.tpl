{# Header section #}

{# Extract block objects for CSS variable computation #}
{% set logo_block = null %}
{% set utilities_block = null %}
{% set navigation_block = null %}
{% for block in section.blocks %}
	{% if block.type == 'header-logo' %}
		{% set logo_block = block %}
	{% endif %}
	{% if block.type == 'header-utilities' %}
		{% set utilities_block = block %}
	{% endif %}
	{% if block.type == 'header-navigation' %}
		{% set navigation_block = block %}
	{% endif %}
{% endfor %}

{# Section settings #}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set use_different_mobile_padding = section.settings.use_different_mobile_padding %}
{% set vertical_padding_mobile = use_different_mobile_padding ? section.settings.vertical_padding_mobile | default(vertical_padding) : vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set horizontal_padding_mobile = full_width and use_different_mobile_padding ? section.settings.horizontal_padding_mobile | default(horizontal_padding) : horizontal_padding %}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Logo settings for CSS variables #}
{% set logo_height = logo_block ? logo_block.settings.height | default(50) : 50 %}
{% set use_different_mobile_height = logo_block ? logo_block.settings.use_different_mobile_height : false %}
{% set logo_height_mobile = use_different_mobile_height and logo_block ? logo_block.settings.height_mobile | default(42) : logo_height %}
{% set logo_position_desktop = section.settings.logo_position_desktop %}
{% set logo_position_mobile = section.settings.use_different_mobile_position ? section.settings.logo_position_mobile : logo_position_desktop %}

{# Utilities settings for CSS variables #}
{% set utilities_format = utilities_block ? utilities_block.settings.format | default('icons_text') : 'icons_text' %}
{% set show_text = utilities_format == 'icons_text' %}
{% set utilities_icon_foreground = utilities_block ? utilities_block.settings.icon_foreground_color %}
{% set utilities_icon_size = utilities_block ? utilities_block.settings.icon_size | default(20) : 20 %}
{% set utilities_icon_size_mobile = utilities_block and utilities_block.settings.use_different_mobile_size ? utilities_block.settings.icon_size_mobile | default(20) : utilities_icon_size %}
{% set utilities_items_gap = utilities_block ? utilities_block.settings.items_gap | default(24) : 24 %}
{% set show_languages_header = utilities_block ? utilities_block.settings.show_languages_header : true %}

{# Search type settings #}
{% set search_type = utilities_block ? utilities_block.settings.search_type | default('expanded') : 'expanded' %}
{% set use_different_mobile_search = utilities_block ? utilities_block.settings.use_different_mobile_search : false %}
{% set search_type_mobile = use_different_mobile_search ? (utilities_block.settings.search_type_mobile | default('icon')) : search_type %}
{% set search_icon_desktop = search_type == 'icon' %}
{% set search_icon_mobile = search_type_mobile == 'icon' %}

{# Navigation settings for CSS variables and mobile categories #}
{% set nav_background = navigation_block ? navigation_block.settings.background_color %}
{% set nav_foreground = navigation_block ? navigation_block.settings.foreground_color %}
{% set nav_vertical_padding = navigation_block ? navigation_block.settings.vertical_padding | default(24) : 24 %}
{% set nav_items_gap = navigation_block ? navigation_block.settings.items_gap | default(16) : 16 %}
{% set nav_uppercase = navigation_block ? navigation_block.settings.nav_uppercase %}
{% set show_mobile_categories = navigation_block ? navigation_block.settings.show_mobile_categories %}
{% set featured_link_color = navigation_block ? navigation_block.settings.featured_link_color %}
{% set nav_divider_color = navigation_block ? navigation_block.settings.nav_divider_color %}

{# Header classes #}
{% set header_with_categories_classes = show_mobile_categories ? 'head-with-mobile-categories' %}
{% set header_logo_classes = logo_position_mobile == 'center' ? 'logo-center' : 'logo-left' %}
{% set header_logo_md_classes = logo_position_desktop == 'center' ? 'logo-md-center' : 'logo-md-left' %}
{% set header_search_icon_class = search_icon_desktop ? 'search-icon-md' %}
{% set header_search_icon_mobile_class = search_icon_mobile ? 'search-icon-mobile' %}

{# Sticky header #}
{% set sticky_val = section.settings.head_fix_desktop %}
{% set is_sticky = sticky_val == true or sticky_val == 'true' or sticky_val == 1 or sticky_val == '1' %}

{# Header styles using CSS custom properties #}
{% set header_styles %}
	{% if background_color %}--header-background: {{ background_color }}; background-color: {{ background_color }};{% endif %}
	{% if text_color %}--header-foreground: {{ text_color }}; color: {{ text_color }}; --header-foreground-opacity-10: {{ text_color }}1A; --header-foreground-opacity-20: {{ text_color }}33;{% endif %}
	{% if nav_background %}--header-desktop-nav-background: {{ nav_background }};{% endif %}
	{% if nav_foreground %}--header-desktop-nav-foreground: {{ nav_foreground }};{% endif %}
	--nav-item-vertical-padding: {{ nav_vertical_padding }}px;
	--nav-item-horizontal-padding: {{ nav_items_gap }}px;
	{% if utilities_icon_foreground %}--header-utilities-foreground: {{ utilities_icon_foreground }};{% endif %}
	{% if featured_link_color %}--header-featured-link-foreground: {{ featured_link_color }};{% endif %}
	{% if nav_divider_color %}--header-nav-divider-color: {{ nav_divider_color }};{% endif %}
	--logo-height-mobile: {{ logo_height_mobile }}px;
	--logo-height-desktop: {{ logo_height }}px;
	--utility-icon-size: {{ utilities_icon_size }}px;
	--utility-icon-size-mobile: {{ utilities_icon_size_mobile }}px;
	--utility-items-gap: {{ utilities_items_gap }}px;
	--header-vertical-padding: {{ vertical_padding }}px;
	--header-vertical-padding-mobile: {{ vertical_padding_mobile }}px;
	{% if full_width %}--header-padding-x: {{ horizontal_padding }}px; --header-padding-x-mobile: {{ horizontal_padding_mobile }}px;{% endif %}
{% endset %}

<div
	class="js-head-main head-main {{ header_with_categories_classes }}"
	data-store="head"
	data-section-id="{{ section.id }}"
	data-section-type="header"
	data-sticky-header="{{ is_sticky ? 'true' : 'false' }}"
	{% if header_styles | trim %}style="{{ header_styles | trim }}"{% endif %}
>
	<div class="head-row {% if page_width %}container{% endif %} {{ header_logo_classes }} {{ header_logo_md_classes }} {{ header_search_icon_class }} {{ header_search_icon_mobile_class }}{% if not show_text %} utilities-icons{% endif %}">

		{# Blocks: logo and utilities #}
		{% for block in section.blocks %}
			{% if block.type == 'header-logo' %}
				{% include 'blocks/header-logo.tpl' with { block: block } %}
			{% endif %}
			{% if block.type == 'header-utilities' %}
				{% include 'blocks/header-utilities.tpl' with {
					block: block,
					logo_position_desktop: logo_position_desktop,
					search_icon_desktop: search_icon_desktop,
					search_icon_mobile: search_icon_mobile,
					show_text: show_text
				} %}
			{% endif %}
		{% endfor %}

	</div>

	{# Mobile main categories #}
	{% if show_mobile_categories and categories | length > 0 %}
		<div class="main-categories-container d-md-none">
			<ul class="nav-categories-mobile list-unstyled list-horizontal {% if nav_uppercase %}text-uppercase{% endif %}">
				{% for category in categories %}
					<li class="nav-item list-item">
						<a href="{{ category.url }}" class="nav-list-link">{{ category.name }}</a>
					</li>
				{% endfor %}
			</ul>
		</div>
	{% endif %}

	{# Desktop navigation #}
	{% for block in section.blocks %}
		{% if block.type == 'header-navigation' %}
			{% include 'blocks/header-navigation.tpl' with { block: block } %}
		{% endif %}
	{% endfor %}
</div>

{# Order notification #}
{% if status_page_url %}
	{% include 'snippets/notification.tpl' with {
		type: 'order',
		status_page_url_notification: status_page_url,
	} %}
{% endif %}

{# Cookies notification #}
{% include 'snippets/notification.tpl' with {
	type: 'cookies',
} %}

{# Mobile navigation #}
{% include 'snippets/header/header-nav-mobile.tpl' %}

{% schema %}
{
  "name": "t:names.header",
  "icon": "HeaderIcon",
  "class": "section-header",
  "static": true,
  "locked_blocks": true,
  "limit": 1,
  "blocks": [
    { "type": "header-logo" },
    { "type": "header-utilities" },
    { "type": "header-navigation" }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "logo_position_desktop",
      "label": "t:settings.logo_position_desktop",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" }
      ],
      "default": "left"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_position",
      "label": "t:settings.use_different_mobile_position",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "logo_position_mobile",
      "label": "t:settings.logo_position_mobile",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" }
      ],
      "default": "center",
      "visible_if": "{{ section.settings.use_different_mobile_position }}"
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
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 24,
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
      "id": "use_different_mobile_padding",
      "label": "t:settings.use_different_mobile_padding",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding_mobile",
      "label": "t:settings.vertical_padding_mobile",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "vertical_padding",
      "visible_if": "{{ section.settings.use_different_mobile_padding }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding_mobile",
      "label": "t:settings.horizontal_padding_mobile",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_padding",
      "visible_if": "{{ section.settings.use_different_mobile_padding }}",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "head_fix_desktop",
      "label": "t:settings.sticky_header",
      "default": true
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
      "label": "t:settings.text",
      "default_setting": "text_color"
    }
  ],
  "default": {
    "blocks": [
      {
        "type": "header-logo",
        "settings": {
          "height": 50
        }
      },
      {
        "type": "header-utilities",
        "settings": {
          "format": "icons",
          "cart_icon": "bag"
        }
      },
      {
        "type": "header-navigation",
        "settings": {
          "nav_uppercase": true,
          "show_categories_link": false,
          "show_mobile_categories": true,
          "show_secondary_menu": false
        }
      }
    ]
  },
  "enabled_on": {
    "layout_templates": ["header"]
  }
}
{% endschema %}
