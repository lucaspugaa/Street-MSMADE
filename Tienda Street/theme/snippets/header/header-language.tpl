{# Language selector utility - Desktop dropdown #}

{% set utility_icon_md_color_class = not secondary_nav ? 'utility-icon-md-colors' %}
{% set utility_icon_only_md_color_class = not show_text and not secondary_nav ? 'utility-icon-md-big' %}

<span class="js-header-dropdown header-utility nav-dropdown {% if secondary_nav %}header-language-secondary{% endif %}">
	<span class="{% if not secondary_nav %}header-icon {{ utility_icon_md_color_class }} {{ utility_icon_only_md_color_class }}{% endif %}">
		<svg class="{% if secondary_nav %}nav-language-icon{% else %}utility-icon{% endif %} icon-inline"><use xlink:href="#world"/></svg>
	</span>
	{% if show_text %}
		<div class="header-language-label utility-text">
		{% for language in languages if language.active %}
			{{ language.country }}
		{% endfor %}
		<svg class="nav-dropdown-icon icon-inline"><use xlink:href="#chevron"/></svg>
		</div>
	{% endif %}
	<div class="js-header-dropdown-content nav-dropdown-content desktop-dropdown desktop-dropdown-small">
		{% include 'snippets/navigation/country-options.tpl' with { show_title: true } %}
	</div>
</span>
