{# Nav Icon Text Item Block — Icon with description for the navigation bar #}

{%- set item = block.settings | default({}) -%}
{% set use_custom_image = item.icon_source == 'custom' and item.custom_image %}
{% set is_mobile_menu = type == 'mobile_menu' %}

{% set wrapper_class = is_mobile_menu ? 'secondary-menu-link secondary-menu-link-icon' : 'navigation-bar-item' %}

{% if is_mobile_menu %}
	<li class="secondary-menu-item">
{% endif %}

  {% if item.link %}
    <a href="{{ item.link }}" class="{{ wrapper_class }}" {% if not is_mobile_menu %}{{ block | block_attributes }}{% endif %}>
  {% elseif is_mobile_menu %}
    <span class="{{ wrapper_class }}">
  {% else %}
    <div class="{{ wrapper_class }}" {{ block | block_attributes }}>
  {% endif %}

    {% if use_custom_image and not is_mobile_menu %}
      {% include 'snippets/image.tpl' with {
        image_src: item.custom_image,
        image_alt: '',
        image_lazy_js: true,
        image_classes: 'fade-in',
      } %}
    {% else %}
      {% include 'snippets/icon.tpl' with { name: item.icon | default('shipping'), class: 'icon-inline' } %}
    {% endif %}

    {% if item.description %}
      <span>{{ item.description | raw }}</span>
    {% endif %}

  {% if item.link %}
    </a>
  {% elseif is_mobile_menu %}
    </span>
  {% else %}
    </div>
  {% endif %}

{% if is_mobile_menu %}
	</li>
{% endif %}

{% schema %}
{
  "name": "t:names.icon_text_item",
  "icon": "HeartIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "icon_source",
      "label": "t:settings.icon_source",
      "options": [
        { "value": "design", "label": "t:options.design_icons" },
        { "value": "custom", "label": "t:options.custom_image" }
      ],
      "default": "design"
    },
    {
      "type": "setting",
      "setting_type": "icon_picker",
      "id": "icon",
      "label": "t:settings.icon",
      "options": [
        { "value": "shipping", "label": "t:options.icon_shipping", "sprite_id": "truck" },
        { "value": "card", "label": "t:options.icon_credit_card", "sprite_id": "credit-card" },
        { "value": "security", "label": "t:options.icon_security" },
        { "value": "returns", "label": "t:options.icon_returns" },
        { "value": "cash", "label": "t:options.icon_cash" },
        { "value": "promotions", "label": "t:options.icon_promotions" },
        { "value": "bag", "label": "t:options.icon_bag" },
        { "value": "cart", "label": "t:options.icon_cart" },
        { "value": "store", "label": "t:options.icon_store" },
        { "value": "gift", "label": "t:options.icon_gift" },
        { "value": "heart", "label": "t:options.icon_heart" },
        { "value": "star", "label": "t:options.icon_star" },
        { "value": "phone", "label": "t:options.icon_phone" },
        { "value": "email", "label": "t:options.icon_email" },
        { "value": "location", "label": "t:options.icon_location" },
        { "value": "world", "label": "t:options.icon_world" },
        { "value": "calendar", "label": "t:options.icon_calendar" },
        { "value": "check", "label": "t:options.icon_check" },
        { "value": "whatsapp", "label": "WhatsApp", "sprite_id": "whatsapp-alt" }
      ],
      "default": "shipping",
      "visible_if": "{{ block.settings.icon_source == 'design' }}"
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "custom_image",
      "label": "t:settings.image",
      "visible_if": "{{ block.settings.icon_source == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "description",
      "label": "t:settings.description",
      "default": "t:defaults.icon_text.item_1_description"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.link"
    }
  ]
}
{% endschema %}
