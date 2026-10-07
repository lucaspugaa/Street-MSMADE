{# Nav Contact Block — contact data (phone, WhatsApp, email) for the navigation bar #}

{% set alignment = block.settings.alignment | default('right') %}
{% set justify_class = alignment == 'center' ? 'justify-content-center' : (alignment == 'right' ? 'justify-content-end' : 'justify-content-start') %}
{% set block_gap = block.settings.gap | default(16) %}
{% set is_mobile_menu = type == 'mobile_menu' %}

{% set has_whatsapp = block.settings.show_whatsapp and store.whatsapp %}
{% set has_phone = block.settings.show_phone and store.phone %}
{% set has_email = block.settings.show_email and store.email %}
{% set has_contact_info = has_whatsapp or has_phone or has_email %}

{% set item_class = is_mobile_menu ? 'secondary-menu-item' : 'navigation-bar-item' %}
{% set link_class = is_mobile_menu ? 'secondary-menu-link secondary-menu-link-icon' : '' %}
{% set icon_class = 'icon-inline' %}

{% if has_contact_info %}
	{% if not is_mobile_menu %}
		<div class="navigation-bar-block {{ justify_class }}" {{ block | block_attributes }}>
	{% endif %}
			<ul class="list-unstyled" {% if not is_mobile_menu %}style="gap: {{ block_gap }}px"{% endif %}>
				{% if has_whatsapp %}
					<li class="{{ item_class }}">
						<a class="{{ link_class }}" href="{{ store.whatsapp }}">
							<svg class="{{ icon_class }}"><use xlink:href="#whatsapp-alt"/></svg>
							{{ store.whatsapp | replace('https://wa.me/', '') }}
						</a>
					</li>
				{% endif %}
				{% if has_phone %}
					<li class="{{ item_class }}">
						<a class="{{ link_class }}" href="tel:{{ store.phone }}">
							<svg class="{{ icon_class }}"><use xlink:href="#phone"/></svg>
							{{ store.phone }}
						</a>
					</li>
				{% endif %}
				{% if has_email %}
					<li class="{{ item_class }}">
						<a class="{{ link_class }}" href="mailto:{{ store.email }}">
							<svg class="{{ icon_class }}"><use xlink:href="#email"/></svg>
							{{ store.email }}
						</a>
					</li>
				{% endif %}
			</ul>
	{% if not is_mobile_menu %}
		</div>
	{% endif %}
{% endif %}

{% schema %}
{
  "name": "t:names.navbar_contact",
  "icon": "TelephoneIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_phone",
      "label": "t:settings.show_phone",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_whatsapp",
      "label": "t:settings.show_whatsapp",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_email",
      "label": "t:settings.show_email",
      "default": true
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
      "default": "right"
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
      "name": "t:names.navbar_contact",
      "settings": {
        "show_phone": true,
        "show_whatsapp": true,
        "show_email": true,
        "alignment": "right",
        "gap": 16
      }
    }
  ]
}
{% endschema %}
