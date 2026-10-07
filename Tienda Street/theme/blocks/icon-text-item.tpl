{# Icon Text Item Block - Icon with title and description #}

{%- set item = block.settings | default({}) -%}
{% set icon_name = item.icon | default('shipping') == 'whatsapp' ? 'whatsapp-alt' : item.icon | default('shipping') %}
{% set use_custom_image = item.icon_source == 'custom' and item.custom_image %}
{% set direction = content_direction | default('vertical') %}
{% set alignment = alignment | default('center') %}
{% set icon_size = icon_size | default(60) %}
{% set title_size_value = title_size | default('h6') %}
{% set is_custom = title_size_value == 'custom' %}
{% set title_size_class = title_size_value == 'paragraph_small' ? 'font-small' : (title_size_value == 'paragraph' ? '' : title_size_value) %}
{% set description_size_class = description_size | default('paragraph') == 'paragraph_small' ? 'font-small' : (description_size | default('paragraph') == 'paragraph_big' ? 'font-big' : '') %}

{% if direction == 'vertical' %}
	{% set align_class = alignment == 'left' ? 'align-items-start' : (alignment == 'right' ? 'align-items-end' : 'align-items-center') %}
	{% set item_class = 'd-flex flex-column ' ~ align_class %}
{% else %}
	{% set item_class = 'icon-text-item-horizontal' %}
{% endif %}

{% if item.link %}
	<a href="{{ item.link }}" class="icon-text-item {{ item_class }}" {{ block | block_attributes }}>
{% else %}
	<div class="icon-text-item {{ item_class }}" {{ block | block_attributes }}>
{% endif %}

	{% set show_icon = show_icon is not same as(false) %}
	{% if show_icon %}
		<div class="icon-text-item-icon flex-shrink-0" style="width: {{ icon_size }}px; min-width: {{ icon_size }}px;">
			{% if use_custom_image %}
				{% set image_alt = item.custom_image | media_alt | default(item.title | striptags) %}
				{% include 'snippets/image.tpl' with {
					image_src: item.custom_image,
					image_alt: image_alt,
					image_lazy_js: true,
					image_classes: 'fade-in',
					image_width: icon_size,
				} %}
			{% else %}
				{% include 'snippets/icon.tpl' with { name: icon_name, size: icon_size } %}
			{% endif %}
		</div>
	{% endif %}

	<div class="icon-text-item-content">
		{% if item.title %}
			{% if is_custom %}
				{% set block_font = custom_title_font | default(settings.font_headings) %}
				{% set block_size = custom_title_size | default(settings.font_rest_size) %}
				{% set title_class = 'icon-text-item-title heading-custom' %}
				{% set title_style = '--block-font: ' ~ block_font ~ '; --block-font-size: ' ~ block_size ~ 'px;' %}
				{% if custom_title_mobile and custom_title_mobile_size %}
					{% set title_style = title_style ~ ' --block-mobile-font-size: ' ~ custom_title_mobile_size ~ 'px;' %}
				{% endif %}
			{% else %}
				{% set title_class = ('icon-text-item-title ' ~ title_size_class) | trim %}
			{% endif %}
			<div class="{{ title_class }}"{% if title_style %} style="{{ title_style }}"{% endif %}>{{ item.title | raw }}</div>
		{% endif %}
		{% if item.description %}
			<div class="icon-text-item-description {{ description_size_class }}">{{ item.description | raw }}</div>
		{% endif %}
	</div>

{% if item.link %}
	</a>
{% else %}
	</div>
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
      "id": "title",
      "label": "t:settings.title",
      "default": "t:defaults.icon_text.item_1_title"
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
