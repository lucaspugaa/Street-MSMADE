{#
  Announcement Block
  Renders a short text message with optional link.
  Accepts type: 'mobile_menu' to render as secondary-menu-item.
#}

{%- set announcement = block.settings -%}
{% set is_mobile_menu = type == 'mobile_menu' %}
{% set link_class = is_mobile_menu ? 'secondary-menu-link' : 'announcement-link' %}

{% if is_mobile_menu %}
	<li class="secondary-menu-item">
{% else %}
	<div class="announcement" {{ block | block_attributes }}>
{% endif %}

	{% if announcement.link %}
		<a href="{{ announcement.link }}" class="{{ link_class }}">{{ announcement.text | raw }}</a>
	{% else %}
		<span class="{{ link_class }}">{{ announcement.text | raw }}</span>
	{% endif %}

{% if is_mobile_menu %}
	</li>
{% else %}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.announcement",
  "icon": "ListIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "inline_richtext",
      "id": "text",
      "label": "t:settings.announcement_text",
      "default": "t:defaults.announcements.announcement_1"
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
