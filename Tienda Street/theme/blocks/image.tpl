{# Image Block - Public, can be used anywhere #}

{% set img_settings = block.settings %}
{% set block_width = img_settings.width | default('fill') %}
{% set is_priority = is_priority | default(false) %}

{% set has_responsive_images = img_settings.image and img_settings.image_mobile %}
{% set has_image = img_settings.image or img_settings.image_mobile %}
{% set show_placeholder = not has_image %}

{% set image_alt = img_settings.image | media_alt | default(store.name) %}
{% set image_mobile_alt = img_settings.image_mobile | media_alt | default(store.name) %}

<div class="image-block {% if block_width == 'fill' %}block-fill{% endif %}" {{ block | block_attributes }}>
	{% if img_settings.image %}
		{% if img_settings.link %}
			<a href="{{ img_settings.link }}" class="d-block">
		{% endif %}
		{% set desktop_lazy = has_responsive_images or not is_priority %}
		{% include 'snippets/image.tpl' with {
			image_src: img_settings.image,
			image_alt: image_alt,
			image_classes: (has_responsive_images ? 'd-none d-md-block ') ~ 'img-fluid' ~ (desktop_lazy ? ' fade-in'),
			image_priority_high: not has_responsive_images and is_priority,
			image_lazy_js: desktop_lazy,
			image_width: img_settings.image_width,
			image_height: img_settings.image_height,
			image_aspect_ratio: img_settings.image_width and img_settings.image_height,
		} %}
		{% if not is_priority %}
			<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-none d-md-block' }}"></div>
		{% endif %}
		{% if img_settings.image_mobile %}
			{% include 'snippets/image.tpl' with {
				image_src: img_settings.image_mobile,
				image_alt: image_mobile_alt,
				image_classes: (has_responsive_images ? 'd-md-none ') ~ 'img-fluid' ~ (not is_priority ? ' fade-in'),
				image_priority_high: is_priority,
				image_lazy_js: not is_priority,
				image_width: img_settings.image_mobile_width,
				image_height: img_settings.image_mobile_height,
				image_aspect_ratio: img_settings.image_mobile_width and img_settings.image_mobile_height,
			} %}
			{% if not is_priority %}
				<div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-md-none' }}"></div>
			{% endif %}
		{% endif %}
		{% if img_settings.link %}
			</a>
		{% endif %}
	{% elseif show_placeholder %}
		{# Fallback placeholder only when no image is configured at all. #}
		{% set desktop_lazy = not is_priority %}
		{% include 'snippets/image.tpl' with {
			image_src: 'images/placeholders/banners/banner-1.webp' | static_url,
			image_alt: 'accessibility.banner' | t,
			image_classes: 'img-fluid' ~ (desktop_lazy ? ' fade-in'),
			image_priority_high: is_priority,
			image_lazy_js: desktop_lazy,
		} %}
		{% if desktop_lazy %}
			<div class="placeholder placeholder-fade"></div>
		{% endif %}
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.image",
  "tags": ["general"],
  "category": "basic",
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:settings.image"
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
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.link"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "fit", "label": "t:options.fit" },
        { "value": "fill", "label": "t:options.fill" }
      ],
      "default": "fill"
    }
  ],
  "presets": [
    {
      "name": "t:names.image",
      "category": "t:categories.media"
    }
  ]
}
{% endschema %}
