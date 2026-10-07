{#
  Navigation List Hamburger
  Recursive navigation tree for mobile hamburger menu with submenus.
#}
{% set subitem = subitem | default(false) %}

{% for item in navigation %}

	{% set nav_panel_id = 'nav-panel-id-' ~ random() %}

	{# Collect mobile banner blocks assigned to this item or to all items #}
	{% set item_banners = [] %}
	{% if not subitem and nav_banner_blocks is defined and nav_banner_blocks | length > 0 %}
		{% for banner_block in nav_banner_blocks %}
			{% set is_banner = banner_block.type == 'navigation-banner' and banner_block.settings.image and banner_block.settings.show_on_mobile %}
			{% set matches_item = banner_block.settings.menu_item == item.name or banner_block.settings.menu_item == '_all' %}
			{% if is_banner and matches_item %}
				{% set item_banners = item_banners | merge([banner_block]) %}
			{% endif %}
		{% endfor %}
	{% endif %}
	{% set has_panel = item.subitems or item_banners | length > 0 %}

	{% if has_panel %}
		<div class="nav-item item-with-subitems" data-component="menu.item">
			<button class="js-modal-open-private nav-list-link {{ item.current ? 'selected' }}" data-target="#{{ nav_panel_id }}" data-modal-url="#{{ nav_panel_id }}">
				{{ item.name }}
				<span class="nav-list-arrow">
					<svg class="icon-inline"><use xlink:href="#chevron"/></svg>
				</span>
			</button>

			{% embed 'snippets/modals/modal.tpl' with {
				modal_id: nav_panel_id,
				data_component: 'nav-hamburger',
				dismiss_all_modals_on_close: 'true',
				modal_footer: false,
				back_button: true,
				title: item.name,
				position: {
					appear_from: 'right',
				},
				layout: {
					overlay: false,
				},
				modal_classes: {
					modal: 'modal-nav-hamburger',
					body: 'nav-hamburger-body',
					close_button: 'js-close-all-nav-modals',
					close_icon: 'icon-inline',
				}
			} %}
				{% block modal_body %}
					{% if item.isCategory %}
						<div class="nav-item">
							<a class="nav-list-link {{ item.current ? 'selected' }}" href="{{ item.url }}">
								{% if item.isRootCategory %}
									{{ 'general.view_all_products' | t }}
								{% else %}
									{{ 'general.view_all_in' | t }} {{ item.name }}
								{% endif %}
							</a>
						</div>
					{% endif %}
					{% if item.subitems %}
						{% include 'snippets/navigation/navigation-list-hamburger.tpl' with { 'navigation' : item.subitems, 'subitem' : true } %}
					{% endif %}
					{% for banner_block in item_banners %}
						<div class="nav-mobile-banner-item">
							{% include 'blocks/navigation-banner.tpl' with { block: banner_block } %}
						</div>
					{% endfor %}
				{% endblock %}
			{% endembed %}

		</div>
	{% else %}
		<div class="nav-item" data-component="menu.item">
			<a class="nav-list-link {{ item.current ? 'selected' }}" href="{% if item.url %}{{ item.url | setting_url }}{% else %}#{% endif %}">{{ item.name }}</a>
		</div>
	{% endif %}
{% endfor %}
