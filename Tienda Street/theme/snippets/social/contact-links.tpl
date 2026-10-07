{#
  Contact Links
  Store contact info list: WhatsApp, phone, email with optional icons.
#}
<ul class="list list-unstyled">
	{% set list_classes = 'contact-link-item' %}
	{% set list_with_icons_classes = with_icons ? 'd-flex align-items-center' %}
	{% set icon_classes = 'contact-link-icon icon-inline' %}
	{% if store.whatsapp and not phone_and_mail_only %}
		<li class="{{ list_classes }} {{ list_with_icons_classes }}">
			<a href="{{ store.whatsapp }}">
				{% if with_icons %}
					<svg class="{{ icon_classes }}"><use xlink:href="#whatsapp"/></svg>
				{% endif %}
				{{ store.whatsapp | trim('https://wa.me/') }}
			</a>
		</li>
	{% endif %}
	{% if store.phone %}
		<li class="{{ list_classes }} {{ list_with_icons_classes }}">
			<a href="tel:{{ store.phone }}">
				{% if with_icons %}
					<svg class="{{ icon_classes }}"><use xlink:href="#phone"/></svg>
				{% endif %}
				{{ store.phone }}
			</a>
		</li>
	{% endif %}
	{% if store.email %}
		<li class="{{ list_classes }} {{ list_with_icons_classes }}">
			<a href="mailto:{{ store.email }}">
				{% if with_icons %}
					<svg class="{{ icon_classes }}"><use xlink:href="#email"/></svg>
				{% endif %}
				{{ store.email }}
			</a>
		</li>
	{% endif %}
	{% if store.address and not is_order_cancellation and not phone_and_mail_only %}
		<li class="{{ list_classes }} {{ list_with_icons_classes }}">
			{% if with_icons %}
				<svg class="{{ icon_classes }}"><use xlink:href="#location"/></svg>
			{% endif %}
			{{ store.address }}
		</li>
	{% endif %}
	{% if store.blog and not phone_and_mail_only %}
		<li class="{{ list_classes }} {{ list_with_icons_classes }}">
			<a target="_blank" rel="noopener noreferrer" href="{{ store.blog }}">
				{% if with_icons %}
					<svg class="{{ icon_classes }}"><use xlink:href="#comments"/></svg>
				{% endif %}
				{{ 'footer.visit_blog' | t }}
			</a>
		</li>
	{% endif %}
</ul>
