{# Category Item Block - Individual category in featured categories section #}

{% set item_text = block.settings.text | default('') %}
{% set item_link = block.settings.link %}
{% set item_image = block.settings.image %}

<div class="category-item" {{ block | block_attributes }}>
	{% if item_link %}
		<a href="{{ item_link }}" class="category-item-link">
	{% else %}
		<span class="category-item-link">
	{% endif %}

	{% if is_image_thumbnail %}
		<div class="category-item-image">
			{% if item_image %}
				{% set image_alt = item_image | media_alt | default('accessibility.category_image' | t) %}
				{% include 'snippets/image.tpl' with {
					image_src: item_image,
					image_alt: image_alt,
					image_classes: 'fade-in',
					image_lazy_js: true,
					image_width: image_size,
				} %}
			{% else %}
				{% set placeholder_num = ((category_index | default(0)) % 15) + 1 %}
				{% include 'snippets/image.tpl' with {
					image_src: ('images/placeholders/categories/category-' ~ placeholder_num ~ '.webp') | static_url,
					image_alt: 'accessibility.category_image' | t,
					image_classes: 'fade-in',
					image_lazy_js: true,
					image_width: image_size,
				} %}
			{% endif %}
		</div>
	{% endif %}

	{% if item_text %}
		<span class="category-item-text text-{{ items_text_alignment | default('left') }}">{{ item_text | raw }}</span>
	{% endif %}

	{% if item_link %}
		</a>
	{% else %}
		</span>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.category",
  "icon": "link",
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:names.image",
      "visible_if": "{{ block.parent.settings.category_type == 'image_thumbnail' }}"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "text",
      "label": "t:names.text"
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
