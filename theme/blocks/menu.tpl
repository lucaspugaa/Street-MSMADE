{# Menu Block - Public, can be used anywhere #}

{% set menu_id = block.settings.menu %}
{% set heading = block.settings.heading %}
{% set show_as_accordion = block.settings.show_as_accordion %}

<div class="menu-block" {{ block | block_attributes }}>
	{% if heading %}
		<h3 class="menu-block-heading">{{ heading }}</h3>
	{% endif %}
	
	<nav class="menu-block-nav">
		<ul class="menu-block-list list-unstyled">
			{% for item in menus[menu_id] %}
				<li class="menu-block-item">
					<a href="{{ item.url }}" class="menu-block-link">{{ item.name }}</a>
					{% if item.subitems and show_as_accordion %}
						<ul class="menu-block-sublist list-unstyled">
							{% for subitem in item.subitems %}
								<li class="menu-block-subitem">
									<a href="{{ subitem.url }}" class="menu-block-sublink">{{ subitem.name }}</a>
								</li>
							{% endfor %}
						</ul>
					{% endif %}
				</li>
			{% endfor %}
		</ul>
	</nav>
</div>

{% schema %}
{
  "name": "t:names.menu",
  "settings": [
    {
      "type": "setting",
      "setting_type": "menu",
      "id": "menu",
      "label": "t:settings.menu",
      "default": "main-menu"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "heading",
      "label": "t:settings.title"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_as_accordion",
      "label": "t:settings.show_submenus",
      "default": false
    }
  ],
  "presets": [
    {
      "name": "t:names.menu",
      "category": "t:categories.basic"
    }
  ]
}
{% endschema %}
