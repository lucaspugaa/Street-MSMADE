{# Newsletter Form - Reusable newsletter subscription form
	Parameters:
	- form_data_store: string (default: 'home-newsletter-form') — identifies the form submission
	- form_color: string (optional) — custom color for input/button border and text
	- ajax_submit: boolean (default: false) — if true, JS handles submission via LS.newsletter()
	- submit_label: string (default: newsletter.submit translation) — submit button text
	- submit_classes: string (default: standard newsletter button classes) — submit button classes
#}

{% set form_data_store = form_data_store | default('home-newsletter-form') %}
{% set submit_label = submit_label | default('newsletter.submit' | t) %}
{% set submit_classes = submit_classes | default('newsletter-form-button btn btn-inline btn-outline') %}

<form
	class="{% if ajax_submit %}js-newsletter-form-ajax{% endif %} newsletter-form"
	method="post"
	action="/winnie-pooh"
	{% if not ajax_submit %}onsubmit="this.setAttribute('action', '');"{% endif %}
	data-store="{{ form_data_store }}"
>
	<div class="newsletter-form-wrapper input-append">
		<input
			type="email"
			name="email"
			class="newsletter-form-input form-control"
			placeholder="{{ 'newsletter.placeholder' | t }}"
			required
			aria-label="{{ 'newsletter.placeholder' | t }}"
			{% if form_color %}style="border-color: {{ form_color }}; color: {{ form_color }};"{% endif %}
		/>
		<div class="winnie-pooh" style="display: none;">
			<label for="winnie-pooh-{{ form_data_store }}">{{ 'contact.do_not_fill' | t }}</label>
			<input id="winnie-pooh-{{ form_data_store }}" type="text" name="winnie-pooh" />
		</div>
		<input type="hidden" name="name" value="{{ 'newsletter.anonymous_name' | t }}" />
		<input type="hidden" name="message" value="{{ 'newsletter.subscription_request' | t }}" />
		<input type="hidden" name="type" value="newsletter" />
		<button
			type="submit"
			name="contact"
			value="{{ submit_label }}"
			class="js-newsletter-form-submit {{ submit_classes }}"
			{% if form_color %}style="color: {{ form_color }}; border-color: {{ form_color }};"{% endif %}
		>
			<span class="js-newsletter-form-submit-label">{{ submit_label }}</span>
			{% if ajax_submit %}
				<span class="js-newsletter-form-spinner form-spinner" style="display: none;">
					{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
				</span>
			{% endif %}
		</button>
	</div>
	{% if ajax_submit %}
		<div class="js-newsletter-success-alert alert alert-success newsletter-form-alert" style="display: none;">{{ 'newsletter.thanks_subscribe' | t }}</div>
		<div class="js-newsletter-error-alert alert alert-danger newsletter-form-alert" style="display: none;">{{ 'newsletter.email_required' | t }}</div>
	{% else %}
		{% if contact and contact.type == 'newsletter' %}
			{% if contact.success %}
				<div class="alert alert-success newsletter-form-alert">{{ 'newsletter.thanks_subscribe' | t }}</div>
			{% else %}
				<div class="alert alert-danger newsletter-form-alert">{{ 'newsletter.email_required' | t }}</div>
			{% endif %}
		{% endif %}
	{% endif %}
</form>
