{% if type == 'payments' %}
	{% set item = payment %}
	{% set settings = settings.payments %}
	{% set filter = payment_logo %}
{% elseif type == 'shipping' %}
	{% set item = shipping %}
	{% set settings = settings.shipping %}
	{% set filter = shipping_logo %}
{% endif %}

{% for item in settings %}

	{% if type == 'payments' %}
		{% set img_url = item | payment_new_logo %}
	{% elseif type == 'shipping' %}
		{% set img_url = item | shipping_logo %}
	{% endif %}

	{% include 'snippets/image.tpl' with {
		image_src: img_url,
		image_alt: item,
		image_classes: 'icon-logo ' ~ logo_img_classes,
		image_lazy_js: true,
		image_thumbs: false,
		image_width: 40,
		image_height: 25,
	} %}
{% endfor %}
