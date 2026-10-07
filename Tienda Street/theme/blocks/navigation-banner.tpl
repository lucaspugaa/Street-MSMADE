{# Navigation Banner #}

{% set banner_image = block.settings.image %}
{% set banner_image_mobile = block.settings.image_mobile %}
{% set banner_url = block.settings.url %}
{% set show_on_mobile = block.settings.show_on_mobile %}
{% set use_mobile_image = block.settings.use_mobile_image %}
{% set banner_title = block.settings.title | default('') %}

{% set has_image = banner_image %}
{% set has_mobile_image = use_mobile_image and banner_image_mobile %}
{% set has_responsive_images = has_image and has_mobile_image %}
{% set image_alt = banner_image | media_alt | default('general.banner' | t) %}
{% set image_mobile_alt = banner_image_mobile | media_alt | default('general.banner' | t) %}

{% if has_image %}

	{% if banner_url %}
		<a href="{{ banner_url }}" class="nav-banner-item" aria-label="{{ banner_title ? banner_title : 'general.banner' | t }}">
	{% else %}
		<div class="nav-banner-item">
	{% endif %}

		{% include 'snippets/image.tpl' with {
			image_src: banner_image,
			image_alt: image_alt,
			image_lazy_js: true,
			image_data_expand: '-1',
			image_classes: 'nav-banner-item-img fade-in' ~ (has_responsive_images ? ' d-none d-md-block'),
		} %}

		{% if has_responsive_images %}
			{% include 'snippets/image.tpl' with {
				image_src: banner_image_mobile,
				image_alt: image_mobile_alt,
				image_lazy_js: true,
				image_data_expand: '-1',
				image_classes: 'nav-banner-item-img fade-in d-md-none',
			} %}
		{% endif %}

		{% if banner_title %}
			<p class="nav-banner-item-title">{{ banner_title }}</p>
		{% endif %}

	{% if banner_url %}
		</a>
	{% else %}
		</div>
	{% endif %}

{% endif %}

{% schema %}
{
  "name": "t:names.banner",
  "icon": "PictureIcon",
  "settings": [
    {
      "type": "paragraph",
      "content": "t:content.navigation_banner_description"
    },
    {
      "type": "setting",
      "setting_type": "menu_item",
      "id": "menu_item",
      "label": "t:settings.menu_item_name"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_on_mobile",
      "label": "t:settings.show_on_mobile",
      "default": true
    },
    {
      "type": "header",
      "content": "t:content.content"
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_mobile_image",
      "label": "t:settings.use_mobile_image",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image_mobile",
      "label": "t:settings.image_mobile",
      "visible_if": "{{ block.settings.use_mobile_image }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "title",
      "label": "t:settings.title"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "url",
      "label": "t:settings.link"
    }
  ],
  "presets": [
    {
      "name": "t:names.banner",
      "category": "t:categories.media"
    }
  ]
}
{% endschema %}
