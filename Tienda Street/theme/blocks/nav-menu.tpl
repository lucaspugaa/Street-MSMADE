{# Nav Menu Block — linklist (level 1 only) for the navigation bar #}

{% set menu_id = block.settings.menu %}
{% set alignment = block.settings.alignment | default('center') %}
{% set justify_class = alignment == 'center' ? 'justify-content-center' : (alignment == 'right' ? 'justify-content-end' : 'justify-content-start') %}
{% set is_mobile_menu = type == 'mobile_menu' %}

{% set block_gap = block.settings.gap | default(16) %}
{% set item_class = is_mobile_menu ? 'secondary-menu-item' : 'navigation-bar-menu-item' %}
{% set link_class = is_mobile_menu ? 'secondary-menu-link' : 'navigation-bar-menu-link' %}

{% if menu_id and menus[menu_id] %}
	<ul class="{% if not is_mobile_menu %}navigation-bar-block {{ justify_class }}{% endif %} list-unstyled" {% if not is_mobile_menu %}{{ block | block_attributes }} style="gap: {{ block_gap }}px"{% endif %}>
		{% for item in menus[menu_id] %}
			<li class="{{ item_class }}">
				<a class="{{ link_class }}" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
			</li>
		{% endfor %}
	</ul>
{% endif %}

{% schema %}
{
  "name": "t:names.navbar_menu",
  "icon": "MenuIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "menu",
      "id": "menu",
      "label": "t:settings.navbar_menu_to_show"
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "alignment",
      "label": "t:settings.desktop_alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
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
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 120,
      "step": 2,
      "unit": "px",
      "default": 16,
      "icon": "horizontal_spacing"
    }
  ],
  "presets": [
    {
      "name": "t:names.navbar_menu",
      "settings": { "alignment": "center", "gap": 16 }
    }
  ]
}
{% endschema %}
