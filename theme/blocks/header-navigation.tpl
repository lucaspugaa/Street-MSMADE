{# Header Desktop Navigation #}

{# Navigation settings from block #}
{% set nav_uppercase = block.settings.nav_uppercase %}
{% set show_categories_link = block.settings.show_categories_link %}
{% set show_featured_link = block.settings.show_featured_link %}
{% set featured_link_item = show_featured_link ? block.settings.featured_link_item %}
{% set featured_link_color = block.settings.featured_link_color %}
{% set show_secondary_menu = block.settings.show_secondary_menu %}
{% set secondary_menu_id = block.settings.menu %}

{# Derived layout classes #}
{% set secondary_menu_links = secondary_menu_id ? menus[secondary_menu_id] | default([]) : [] %}
{% set has_secondary_menu = show_secondary_menu and secondary_menu_links | length > 0 %}
{% set has_languages = languages | length > 1 %}
{% set utilities_languages_secondary_nav = has_languages and show_text %}
{% set nav_secondary_col = has_secondary_menu or utilities_languages_secondary_nav %}
{% set nav_alignment_desktop = block.settings.nav_alignment_desktop | default('left') %}
{% set nav_desktop_grid_class = 'nav-desktop-grid' ~ (nav_alignment_desktop == 'center' ? ' nav-desktop-grid-center') %}
{% set nav_desktop_text_class = nav_uppercase ? 'nav-desktop-uppercase' %}

{# Section-level layout (accessed via inherited scope) #}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}

{# Reusable inline padding for full-width dropdowns #}
{% set horizontal_padding_style = full_width and horizontal_padding ? 'padding-left: ' ~ horizontal_padding ~ 'px; padding-right: ' ~ horizontal_padding ~ 'px;' : '' %}

<div class="nav-desktop-container d-none d-md-block" {{ block | block_attributes }}>
	<div class="js-nav-desktop-container {{ nav_desktop_grid_class }} {% if page_width %}container{% endif %}" style="visibility:hidden; height:0; {{ horizontal_padding_style }}">

		{# Categories column #}
		{% if show_categories_link %}
			<div class="js-desktop-main-categories-col nav-desktop-grid-categories nav-desktop-list {{ nav_desktop_text_class }}">
				<nav class="nav-desktop position-relative">
					<ul class="nav-desktop-list list-unstyled">
						<li class="nav-item nav-main-item nav-dropdown">
							<a href="{{ store.categories_url }}" class="nav-list-link nav-list-link-heading">
								{{ 'general.categories' | t }}
								<svg class="nav-list-link-icon icon-inline"><use xlink:href="#chevron"/></svg>
							</a>
							<div class="js-desktop-dropdown nav-dropdown-content desktop-dropdown">
								<div class="{% if page_width %}container{% endif %} desktop-dropdown-container" {% if horizontal_padding_style %}style="{{ horizontal_padding_style }}"{% endif %}>
						<ul class="desktop-list-subitems list-unstyled">
									{% for category in categories %}
										<li class="nav-item">
											<a href="{{ category.url }}" class="nav-list-link nav-list-link-heading">{{ category.name }}</a>
											{% set subcategories = category.subcategories(false) %}
											{% if subcategories %}
												<ul class="list-subitems list-unstyled">
													{% for subcategory in subcategories %}
														<li class="nav-item">
															<a href="{{ subcategory.url }}" class="nav-list-link">{{ subcategory.name }}</a>
														</li>
													{% endfor %}
												</ul>
											{% endif %}
										</li>
									{% endfor %}
								</ul>
							</div>
							</div>
						</li>
					</ul>
				</nav>
			</div>
		{% endif %}

		{# Main navigation column #}
		<div class="js-desktop-nav-col nav-desktop-grid-main {{ nav_desktop_text_class }}">
			<nav class="nav-desktop position-relative">
				<button type="button" class="js-nav-desktop-list-arrow js-nav-desktop-list-arrow-left nav-desktop-list-arrow nav-desktop-list-arrow-left disable" aria-label="{{ 'general.previous' | t }}" style="display: none">
					<svg class="nav-arrow-icon icon-flip-horizontal icon-inline"><use xlink:href="#chevron"/></svg>
				</button>
				<ul class="js-nav-desktop-list nav-desktop-list list-unstyled">
				{% for item in navigation %}
					{% set is_featured = featured_link_item and item.name == featured_link_item %}
					{# Collect banner blocks assigned to this item or to all items #}
					{% set matched_banners = [] %}
					{% for child_block in block.blocks %}
						{% set is_banner = child_block.type == 'navigation-banner' and child_block.settings.image %}
						{% set matches_item = child_block.settings.menu_item == item.name or child_block.settings.menu_item == '_all' %}
						{% if is_banner and matches_item %}
							{% set matched_banners = matched_banners | merge([child_block]) %}
						{% endif %}
					{% endfor %}
					{% set banner_count = matched_banners | length %}
					{% set has_dropdown = item.subitems or banner_count > 0 %}

					<li class="nav-item nav-main-item {% if has_dropdown %}nav-dropdown{% endif %}">
						<a href="{{ item.url }}" class="nav-list-link {% if is_featured %}nav-list-link-featured{% endif %} {% if is_featured and featured_link_color %}nav-list-link-featured-color{% endif %}" {% if is_featured and featured_link_color %}style="color: {{ featured_link_color }} !important;"{% endif %}>
							{{ item.name }}
							{% if has_dropdown %}
								<svg class="nav-list-link-icon icon-inline" {% if is_featured and featured_link_color %}style="fill: {{ featured_link_color }} !important;"{% endif %}><use xlink:href="#chevron"/></svg>
							{% endif %}
						</a>
							{% if has_dropdown %}
								{# Links span remaining columns; 5+ banners stack on a second row #}
								{% set col_count = (banner_count == 0 or banner_count >= 5) ? 5 : max(1, 5 - banner_count) %}

								<div class="js-desktop-dropdown nav-dropdown-content desktop-dropdown">
									<div class="{% if page_width %}container{% endif %} desktop-dropdown-container" {% if horizontal_padding_style %}style="{{ horizontal_padding_style }}"{% endif %}>
										{% if item.subitems %}
											<ul class="desktop-list-subitems list-unstyled" {% if banner_count > 0 %}style="grid-column: span {{ col_count }}; column-count: {{ col_count }};"{% endif %}>
												{% for subitem in item.subitems %}
													<li class="nav-item">
														<a href="{{ subitem.url }}" class="nav-list-link nav-list-link-heading">{{ subitem.name }}</a>
														{% if subitem.subitems %}
															<ul class="list-subitems list-unstyled">
																{% for subsubitem in subitem.subitems %}
																	<li class="nav-item">
																		<a href="{{ subsubitem.url }}" class="nav-list-link">{{ subsubitem.name }}</a>
																	</li>
																{% endfor %}
															</ul>
														{% endif %}
													</li>
												{% endfor %}
											</ul>
										{% endif %}
										{% if banner_count > 0 %}
											<div class="nav-desktop-banners">
												{% for child_block in matched_banners %}
													{% include 'blocks/navigation-banner.tpl' with { block: child_block, } %}
												{% endfor %}
											</div>
										{% endif %}
									</div>
								</div>
							{% endif %}
						</li>
					{% endfor %}
				</ul>
				<button type="button" class="js-nav-desktop-list-arrow js-nav-desktop-list-arrow-right nav-desktop-list-arrow nav-desktop-list-arrow-right" aria-label="{{ 'general.next' | t }}" style="display: none">
					<svg class="nav-arrow-icon icon-inline"><use xlink:href="#chevron"/></svg>
				</button>
			</nav>
		</div>

		{# Secondary navigation column #}
		{% if has_secondary_menu %}
			<div class="js-desktop-secondary-nav-col nav-desktop-secondary">
				<ul class="list-unstyled nav-desktop-secondary-list">
					{% for item in secondary_menu_links %}
						<li class="secondary-menu-item">
							<a class="secondary-menu-link nav-list-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
						</li>
					{% endfor %}
				</ul>
				{% if languages | length > 1 and show_text and show_languages_header %}
					{% include 'snippets/header/header-language.tpl' with {secondary_nav: true} %}
				{% endif %}
			</div>
		{% elseif languages | length > 1 and show_text and show_languages_header %}
			<div class="js-desktop-secondary-nav-col nav-desktop-secondary">
				{% include 'snippets/header/header-language.tpl' with {secondary_nav: true} %}
			</div>
		{% endif %}

	</div>
</div>

{% schema %}
{
  "name": "t:names.navigation",
  "icon": "MenuIcon",
  "limit": 1,
  "blocks": [
    { "type": "navigation-banner" }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:content.main_navigation"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "nav_uppercase",
      "label": "t:settings.nav_uppercase",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_categories_link",
      "label": "t:settings.show_categories_link",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_mobile_categories",
      "label": "t:settings.mobile_categories_bar",
      "default": true
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "nav_alignment_desktop",
      "label": "t:settings.nav_alignment_desktop",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" }
      ],
      "default": "center"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 40,
      "step": 2,
      "unit": "px",
      "default": 16,
      "icon": "vertical_padding"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "items_gap",
      "label": "t:settings.space_between_links",
      "min": 0,
      "max": 40,
      "step": 2,
      "unit": "px",
      "default": 16,
      "icon": "horizontal_padding"
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
      "id": "foreground_color",
      "label": "t:settings.text",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "nav_divider_color",
      "label": "t:settings.nav_divider_color",
      "default_setting": "background_color"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_featured_link",
      "label": "t:names.featured_item",
      "default": false,
      "info": "t:info.featured_item_info",
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "menu_item",
      "id": "featured_link_item",
      "label": "t:settings.featured_link_item",
      "visible_if": "{{ block.settings.show_featured_link }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "featured_link_color",
      "label": "t:settings.featured_item_color",
      "default_setting": "text_color",
      "visible_if": "{{ block.settings.show_featured_link }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_secondary_menu",
      "label": "t:names.secondary_navigation",
      "default": false,
      "info": "t:info.secondary_navigation_info",
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "menu",
      "id": "menu",
      "label": "t:settings.menu_to_show",
      "visible_if": "{{ block.settings.show_secondary_menu }}"
    }
  ]
}
{% endschema %}
