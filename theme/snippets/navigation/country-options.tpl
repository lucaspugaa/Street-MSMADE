{% if show_title %}
	<div class="nav-language-title">{{ 'general.languages_currencies' | t }}</div>
{% endif %}
<ul class="list list-unstyled">
	{% for language in languages %}
		<li class="list-item {% if language.active %}list-item-active{% endif %}">
			<a href="{{ language.url }}" class="header-dropdown-link nav-language-link">
				{% include 'snippets/image.tpl' with {
					image_src: language.country | flag_hd_url,
					image_alt: language.country_name,
					image_thumbs: false,
					image_width: 20,
					image_height: 15,
					image_classes: 'nav-language-flag',
					image_lazy: true,
				} %}
				{{ language.country_name }} ({{ language.currency_code }})
			</a>
		</li>
	{% endfor %}
</ul>
