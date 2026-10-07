{# Footer Newsletter Block - Title, description and newsletter form #}

{% set news_title = block.settings.title %}
{% set news_description = block.settings.description %}

<div class="footer-newsletter-container" {{ block | block_attributes }}>
	{% if news_title %}
		<div class="footer-newsletter-title">{{ news_title | raw }}</div>
	{% endif %}
	{% if news_description %}
		<div class="footer-newsletter-description user-content">{{ news_description | raw }}</div>
	{% endif %}
	<form class="footer-newsletter-form newsletter-form" method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="newsletter-form">
		<div class="newsletter-form-wrapper input-append">
			<input type="email" name="email" class="newsletter-form-input form-control" placeholder="{{ 'footer.email_placeholder' | t }}" required aria-label="{{ 'footer.email_placeholder' | t }}" />
			<div class="winnie-pooh" style="display: none;">
			<label for="winnie-pooh-newsletter-footer">{{ 'contact.do_not_fill' | t }}</label>
			<input id="winnie-pooh-newsletter-footer" type="text" name="winnie-pooh"/>
		</div>
		<input type="hidden" name="name" value="{{ 'newsletter.anonymous_name' | t }}" />
		<input type="hidden" name="message" value="{{ 'newsletter.subscription_request' | t }}" />
			<input type="hidden" name="type" value="newsletter" />
			<input type="submit" name="contact" class="newsletter-form-button btn btn-inline btn-outline" value="{{ 'general.send' | t }}" />
		</div>
		{% if contact and contact.type == 'newsletter' %}
			{% if contact.success %}
				<div class="alert alert-success newsletter-form-alert">{{ 'footer.thanks_subscribe' | t }}</div>
			{% else %}
				<div class="alert alert-danger newsletter-form-alert">{{ 'newsletter.email_required' | t }}</div>
			{% endif %}
		{% endif %}
	</form>
</div>

{% schema %}
{
  "name": "t:names.newsletter",
  "icon": "MailIcon",
  "limit": 1,
  "deletable": false,
  "settings": [
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "title",
      "label": "t:settings.title"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "description",
      "label": "t:settings.description"
    }
  ],
  "disabled_on": {
    "templates": ["password"]
  }
}
{% endschema %}
