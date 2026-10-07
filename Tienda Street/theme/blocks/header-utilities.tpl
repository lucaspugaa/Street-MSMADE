{# Header Utilities — menu, search, language, account, cart #}
{# All are located positioned with CSS depending on logo position #}

{% set cart_icon = block.settings.cart_icon | default('bag') %}
{% set show_account_mobile = block.settings.show_account_mobile %}
{% set show_languages_header = block.settings.show_languages_header %}
{% set block_id = block.id %}
{% set block_type = block.type %}

{# Menu toggle — mobile only #}
<div class="menu-container d-md-none" data-block-id="{{ block_id }}" data-block-type="{{ block_type }}">
	<button class="js-modal-open-private header-icon" data-target="#nav-hamburger" data-modal-url="#nav-hamburger" aria-label="{{ 'accessibility.open_menu' | t }}">
		<svg class="utility-icon icon-inline"><use xlink:href="#menu"/></svg>
	</button>
</div>

{# Search #}
<div class="js-search-container search-container" data-block-id="{{ block_id }}" data-block-type="{{ block_type }}">
	<button class="js-search-trigger search-trigger header-icon header-utility"
		aria-label="{{ 'search.placeholder' | t }}" aria-expanded="false">
		{% include 'snippets/icon.tpl' with { name: 'search', class: 'utility-icon' } %}
		{% if show_text %}
			<span class="utility-text search-text d-none d-md-inline">{{ 'search.placeholder' | t }}</span>
		{% endif %}
	</button>
	<div class="js-search-expand-form search-floating-container" aria-hidden="true">
		{% include 'snippets/header/search-form.tpl' %}
	</div>
</div>

{# Language selector — desktop only, icons mode #}
{% if languages | length > 1 and not show_text and show_languages_header %}
	<span class="utilities-language-desktop d-none d-md-inline-block" data-block-id="{{ block_id }}" data-block-type="{{ block_type }}">
		{% include 'snippets/header/header-language.tpl' %}
	</span>
{% endif %}

{# Account #}
<span class="js-header-dropdown header-account header-utility nav-dropdown {% if not show_account_mobile %}d-none d-md-grid{% endif %}" data-block-id="{{ block_id }}" data-block-type="{{ block_type }}">
	<a href="{{ customer ? store.customer_home_url : store.customer_login_url }}" class="header-icon" aria-label="{{ 'general.my_account' | t }}">
		<svg class="utility-icon icon-inline"><use xlink:href="#user"/></svg>
	</a>
	{% if show_text %}
		<span class="utility-text header-account-label d-none d-md-inline">
			{{ 'general.my_account' | t }}
			<svg class="nav-dropdown-icon icon-inline"><use xlink:href="#chevron"/></svg>
		</span>
	{% endif %}
	{# Desktop dropdown — hidden on mobile via CSS #}
	{% set account_short_name = customer ? (customer.name | split(' ') | first) %}
	<div class="js-header-dropdown-content nav-dropdown-content desktop-dropdown desktop-dropdown-small">
		{% if customer %}
			<a href="{{ store.customer_home_url }}" class="header-dropdown-link header-dropdown-link-featured">{{ 'general.greeting' | t | replace('{1}', account_short_name) }}</a>
			<a href="{{ store.customer_logout_url }}" class="header-dropdown-link">{{ 'general.logout' | t }}</a>
		{% else %}
			{% set register_href = store_has_passwordless_login
				? store.customer_login_url
				: store.customer_register_url %}
			<a href="{{ store.customer_login_url }}" class="header-dropdown-link header-dropdown-link-featured">{{ 'general.login' | t }}</a>
			<a href="{{ register_href }}" class="header-dropdown-link">{{ 'general.register' | t }}</a>
		{% endif %}
	</div>
</span>

{# Cart #}
{% set use_ajax_cart = settings.ajax_cart and template != 'cart' %}

{% set cart_content %}
	<span class="header-icon">
		<svg class="utility-icon icon-inline"><use xlink:href="#{{ cart_icon }}"/></svg>
		<span class="js-cart-widget-amount badge {% if cart_icon == 'bag' %}badge-bottom{% endif %}" {% if cart.items_count == 0 %}style="display: none;"{% endif %}>{{ cart.items_count }}</span>
	</span>
	{% if show_text %}
		<div class="utility-text header-cart-text">
			<span class="js-cart-widget-total" data-priceraw="{{ cart.total }}">{{ cart.total | money }}</span>
		</div>
	{% endif %}
{% endset %}

<span id="ajax-cart" class="js-cart-container header-cart header-utility" data-component="cart-button" data-block-id="{{ block_id }}" data-block-type="{{ block_type }}">
	{% if use_ajax_cart %}
		<button class="js-modal-open-private header-utility" data-target="#modal-cart" aria-label="{{ 'general.shopping_cart' | t }}">
			{{ cart_content }}
		</button>
	{% else %}
		<a href="{{ store.cart_url }}" class="header-utility" aria-label="{{ 'general.shopping_cart' | t }}">
			{{ cart_content }}
		</a>
	{% endif %}
</span>

{% schema %}
{
  "name": "t:names.utilities",
  "icon": "SearchIcon",
  "limit": 1,
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "format",
      "label": "t:settings.format_desktop",
      "options": [
        { "value": "icons_text", "label": "t:options.icons_with_text" },
        { "value": "icons", "label": "t:options.icons_only" }
      ],
      "default": "icons"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "search_type",
      "label": "t:settings.search_type",
      "options": [
        { "value": "expanded", "label": "t:options.expanded" },
        { "value": "icon", "label": "t:options.icon_search" }
      ],
      "default": "icon"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_search",
      "label": "t:settings.use_different_mobile_search",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "search_type_mobile",
      "label": "t:settings.search_type",
      "options": [
        { "value": "expanded", "label": "t:options.expanded" },
        { "value": "icon", "label": "t:options.icon_search" }
      ],
      "default": "expanded",
      "visible_if": "{{ block.settings.use_different_mobile_search }}"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "cart_icon",
      "label": "t:settings.cart_icon",
      "options": [
        { "value": "bag", "label": "t:options.bag" },
        { "value": "cart", "label": "t:options.cart" }
      ],
      "default": "bag"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "icon_size",
      "label": "t:settings.icon_size",
      "min": 16,
      "max": 32,
      "step": 2,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_padding"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_size",
      "label": "t:settings.use_different_mobile_size",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "icon_size_mobile",
      "label": "t:settings.icon_size",
      "min": 16,
      "max": 32,
      "step": 2,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_padding",
      "visible_if": "{{ block.settings.use_different_mobile_size }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "items_gap",
      "label": "t:settings.items_gap",
      "min": 0,
      "max": 40,
      "step": 2,
      "unit": "px",
      "default": 20,
      "icon": "horizontal_padding"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_account_mobile",
      "label": "t:settings.show_account_mobile",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_languages_header",
      "label": "t:settings.show_languages_header",
      "default": true
    },
    {
      "type": "header",
      "content": "t:content.icon_colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "icon_foreground_color",
      "label": "t:settings.icon",
      "default_setting": "text_color"
    }
  ]
}
{% endschema %}
