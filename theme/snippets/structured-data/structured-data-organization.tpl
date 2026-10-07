{#
	Structured Data - Organization
	Renders schema.org Organization JSON-LD with the store's name, logo, URL, and social profile links.
#}
{% macro escape_text(text) %}
{{- text | replace('\\', '\\\\') | replace('"', '\"') | replace('</script', '<\\/script') | replace('\r\n', ' ') | replace('\n', ' ') | replace('\r', ' ') | replace('\t', ' ') -}}
{% endmacro %}

<script type="application/ld+json" data-component='structured-data.organization'>
{
	"@context": "https://schema.org",
	"@type": "Organization",
	"name": "{{ _self.escape_text(store.name) }}",
	{% if store.logo %}
	"logo": "{{ 'https:' ~ store.logo }}",
	{% endif %}
	"url": "{{ store.url }}"
	{% set social_links = [store.facebook, store.instagram, store.twitter, store.tiktok, store.pinterest, store.youtube] | filter(v => v is not empty) %}
	{% if social_links | length > 0 %}
	,"sameAs": [
		{% for link in social_links %}
			"{{ link }}"{% if not loop.last %},{% endif %}

		{% endfor %}
	]
	{% endif %}
}
</script>
