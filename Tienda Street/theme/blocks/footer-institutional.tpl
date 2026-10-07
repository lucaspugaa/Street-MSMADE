{# Footer Institutional Block - Logo, description, social links, contact info #}

{% set has_logo = block.settings.logo %}
{% set logo_height = block.settings.logo_height | default(30) %}
{% set has_description = block.settings.description %}
{% set show_social = block.settings.show_social is not same as(false) %}
{% set show_contact = block.settings.show_contact is not same as(false) %}
{% set has_social_network = store.facebook or store.twitter or store.pinterest or store.instagram or store.tiktok or store.youtube %}
{% set has_contact_info = (store.whatsapp or store.phone or store.email or store.address or store.blog) and show_contact %}

<div class="footer-contact-info-container" {{ block | block_attributes }}>

	{# Logo & Description #}
	{% if has_logo or has_description %}
		<div class="footer-institutional-header">
			{% if has_logo %}
				<div class="footer-institutional-image" style="--footer-logo-height: {{ logo_height }}px;">
					{% set image_alt = block.settings.logo | media_alt | default(store.name) %}
					{% include 'snippets/image.tpl' with {
						image_src: block.settings.logo,
						image_alt: image_alt,
						image_lazy_js: true,
						image_classes: 'footer-logo-img fade-in',
					} %}
				</div>
			{% endif %}
		{% if has_description %}
			<div class="footer-institutional-description user-content">
				{{ block.settings.description | raw }}
			</div>
		{% endif %}
		</div>
	{% endif %}

	{# Social links #}
	{% if show_social and has_social_network %}
		<div class="footer-social-container">
			{% for sn in ['instagram', 'facebook', 'youtube', 'tiktok', 'twitter', 'pinterest'] %}
				{% set sn_url = attribute(store, sn) %}
				{% if sn_url %}
					<a class="footer-social-link" href="{{ sn_url }}" target="_blank" rel="noopener noreferrer" aria-label="{{ sn }} {{ store.name }}">
						<svg class="icon-inline"><use xlink:href="#{{ sn }}"/></svg>
					</a>
				{% endif %}
			{% endfor %}
		</div>
	{% endif %}

	{# Contact info #}
	{% if has_contact_info %}
		<ul class="list list-unstyled footer-menu-list">
			{% if store.whatsapp %}
				<li>
					<a href="{{ store.whatsapp }}">{{ store.whatsapp | replace('https://wa.me/', '') }}</a>
				</li>
			{% endif %}
			{% if store.phone %}
				<li>
					<a href="tel:{{ store.phone }}">{{ store.phone }}</a>
				</li>
			{% endif %}
			{% if store.email %}
				<li>
					<a href="mailto:{{ store.email }}">{{ store.email }}</a>
				</li>
			{% endif %}
			{% if store.address %}
				<li>{{ store.address }}</li>
			{% endif %}
			{% if store.blog %}
				<li>
					<a target="_blank" rel="noopener noreferrer" href="{{ store.blog }}">{{ 'footer.visit_blog' | t }}</a>
				</li>
			{% endif %}
		</ul>
	{% endif %}

</div>

{% schema %}
{
  "name": "t:content.institutional",
  "icon": "OnlineStoreIcon",
  "limit": 1,
  "deletable": false,
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "logo",
      "label": "t:settings.footer_logo"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "logo_height",
      "label": "t:settings.height",
      "min": 20,
      "max": 140,
      "step": 2,
      "unit": "px",
      "default": 30,
      "icon": "height"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "description",
      "label": "t:settings.description"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_social",
      "label": "t:settings.show_social",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_contact",
      "label": "t:settings.show_contact",
      "default": true
    }
  ],
  "disabled_on": {
    "templates": ["password"]
  }
}
{% endschema %}
