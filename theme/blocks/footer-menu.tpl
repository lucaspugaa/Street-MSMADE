
{% set menu_id = block.settings.menu %}
{% set menu_title = block.settings.title %}
{% set use_toggle = section.settings.menus_toggle %}
{% set footer_mobile_toggle_title = use_toggle and menu_title %}
{% set footer_nav_classes = footer_mobile_toggle_title ? 'js-accordion-private-container accordion-container footer-menu-accordion' : menu_title ? 'footer-menu-titled' : 'footer-menu-untitled' %}

{% if menu_id %}
	<div class="{{ footer_nav_classes }}" {{ block | block_attributes }}>
		{% if footer_mobile_toggle_title %}
			<a href="#" class="js-accordion-private-toggle-mobile accordion-title footer-menu-toggle-title">
		{% endif %}
			{% if menu_title %}
				<div class="footer-menu-title">
					{{ menu_title | raw }}
				</div>
			{% endif %}
		{% if footer_mobile_toggle_title %}
				<span class="d-md-none">
					<span class="js-accordion-private-toggle-inactive">
						<svg class="accordion-toggle-icon icon-inline"><use xlink:href="#plus"/></svg>
					</span>
					<span class="js-accordion-private-toggle-inactive" style="display: none;">
						<svg class="accordion-toggle-icon icon-inline"><use xlink:href="#minus"/></svg>
					</span>
				</span>
			</a>
			<div class="js-accordion-private-content js-accordion-private-content-mobile footer-menu-accordion-content">
		{% endif %}
				<ul class="list list-unstyled footer-menu-list">
					{% for item in menus[menu_id] %}
						<li>
							<a href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
						</li>
					{% endfor %}
				</ul>
		{% if footer_mobile_toggle_title %}
			</div>
		{% endif %}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.menu",
  "icon": "MenuIcon",
  "limit": 3,
  "settings": [
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "title",
      "label": "t:settings.title"
    },
    {
      "type": "setting",
      "setting_type": "menu",
      "id": "menu",
      "label": "t:settings.menu"
    }
  ],
  "disabled_on": {
    "templates": ["password"]
  }
}
{% endschema %}
