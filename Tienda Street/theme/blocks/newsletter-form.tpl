{# Newsletter Form Block - Reusable newsletter subscription form #}

{% set form_settings = block.settings %}
{% set form_color = form_settings.text_and_lines_color %}

<div class="newsletter-form-block" {{ block | block_attributes }} {% if form_color %}style="--newsletter-form-color: {{ form_color }};"{% endif %}>
	{% include 'snippets/forms/newsletter.tpl' with {
		form_data_store: 'home-newsletter-form',
		form_color: form_color,
	} %}
</div>

{% schema %}
{
  "name": "t:names.newsletter_form",
  "deletable": false,
  "limit": 1,
  "settings": [
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_and_lines_color",
      "label": "t:settings.text_and_lines_color",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.newsletter_form",
      "category": "t:categories.content"
    }
  ]
}
{% endschema %}
