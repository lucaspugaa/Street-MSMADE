<ul class="list list-unstyled">
	{% for language in languages | escape %}
		<li class="list-item {% if language.active %} list-item-active{% endif %}">
			<a href="{{ language.url }}" class="header-dropdown-link">
				{{ language.country_name }}
			</a>
		</li>
	{% endfor %}
</ul>
