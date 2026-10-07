{# Brand Logo Block - Internal, used only in featured-brands section #}

{% set logo_image = block.settings.image %}
{% set logo_link = block.settings.link %}
{% set logo_size = logo_size | default(120) %}

{# Fallback placeholder cycles brand-logo-1..7.webp by position when no image is configured. #}
{% set placeholder_num = ((logo_index | default(0)) % 7) + 1 %}
{% set image_src = logo_image ?: ('images/placeholders/logos/brand-logo-' ~ placeholder_num ~ '.webp') | static_url %}
{% set image_alt = logo_image | media_alt | default('accessibility.logo' | t) %}

<div class="brand-logo-block" {{ block | block_attributes }}>
	{% if logo_link %}
		<a href="{{ logo_link }}" class="brand-logo-link">
	{% endif %}
	{% include 'snippets/image.tpl' with {
		image_src: image_src,
		image_alt: image_alt,
		image_classes: 'fade-in',
		image_lazy_js: true,
		image_width: logo_size,
	} %}
	{% if logo_link %}
		</a>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.logo",
  "icon": "PictureIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:names.logo"
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
