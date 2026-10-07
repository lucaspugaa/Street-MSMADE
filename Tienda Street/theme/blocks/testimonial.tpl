{# Testimonial Block - Private block for testimonials section #}

{% set testimonial = block.settings %}
{% set rating = testimonial.rating %}

{% set card_align = content_alignment == 'left' ? 'align-items-start text-left' : content_alignment == 'right' ? 'align-items-end text-right' : 'align-items-center text-center' %}
{% set header_direction = avatar_layout == 'top' ? 'flex-column' : 'flex-row' %}

<div class="testimonial d-flex flex-column {{ card_align }}">
	{% set has_avatar = testimonial.image %}
	{% set has_meta = testimonial.name or (rating != 'none') %}
	{% if has_avatar or has_meta %}
		{% set meta_align = content_alignment == 'center' ? 'align-items-center' : content_alignment == 'right' ? 'align-items-end' : 'align-items-start' %}
		{% set header_align = header_direction == 'flex-row' ? 'align-items-center' : (content_alignment == 'center' ? 'align-items-center' : content_alignment == 'right' ? 'align-items-end' : 'align-items-start') %}
		<div class="testimonial-header d-inline-flex {{ header_direction }} {{ header_align }}">
			{% if testimonial.image %}
				<div class="testimonial-avatar {% if image_style == 'rounded' %}img-circle{% endif %}">
					{% set image_alt = testimonial.image | media_alt | default(testimonial.name) %}
					{% include 'snippets/image.tpl' with {
						image_src: testimonial.image,
						image_alt: image_alt,
						image_lazy_js: true,
						image_classes: 'fade-in',
					} %}
				</div>
			{% endif %}
			<div class="testimonial-meta d-flex flex-column {{ meta_align }}">
				{% if testimonial.name %}
					<p class="testimonial-name">{{ testimonial.name }}</p>
				{% endif %}
				{% if rating != 'none' %}
					<div class="testimonial-rating d-flex">
						{% set rating_num = rating | default(5) | round %}
						{% for i in 1..5 %}
							<svg class="testimonial-rating-point">
								<use xlink:href="{{ i <= rating_num ? '#star-filled' : '#star' }}"/>
							</svg>
						{% endfor %}
					</div>
				{% endif %}
			</div>
		</div>
	{% endif %}

	{% if testimonial.title %}
		<div class="testimonial-title">{{ testimonial.title | raw }}</div>
	{% endif %}

	{% if testimonial.content %}
		<div class="testimonial-content">{{ testimonial.content | raw }}</div>
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.testimonial",
  "icon": "StarIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:settings.image"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "name",
      "label": "t:settings.name",
      "default": "t:defaults.testimonial.name"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "rating",
      "label": "t:settings.rating",
      "options": [
        { "value": "none", "label": "t:options.none" },
        { "value": "1", "label": "t:options.stars_1" },
        { "value": "2", "label": "t:options.stars_2" },
        { "value": "3", "label": "t:options.stars_3" },
        { "value": "4", "label": "t:options.stars_4" },
        { "value": "5", "label": "t:options.stars_5" }
      ],
      "default": "5"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "title",
      "label": "t:settings.testimonial_title",
      "default": "t:defaults.testimonial.title"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "content",
      "label": "t:settings.description",
      "default": "t:defaults.testimonial.content"
    }
  ]
}
{% endschema %}
