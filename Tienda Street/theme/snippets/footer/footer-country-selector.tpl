{% if languages | length > 1 %}
	<div class="footer-country-selector">
		<button class="js-modal-open-private footer-country-button" data-target="#modal-languages" data-modal-url="#modal-languages" aria-label="{{ 'general.languages_currencies' | t }}">
			<svg class="footer-country-icon icon-inline"><use xlink:href="#world"/></svg>
			<span class="footer-country-text">
				{% for language in languages if language.active %}
					{{ language.country_name }} ({{ language.currency_code }})
				{% endfor %}
			</span>
		</button>
	</div>
{% endif %}
