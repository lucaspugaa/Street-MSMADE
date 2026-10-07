{# Check if store has free shipping without regions or categories #}

{% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}

{# Free shipping visibility variables #}

{% set free_shipping_messages_visible = (product_detail and has_free_shipping) or (not product_detail and has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw == 0) %}

{% set cart_zipcode = product_detail ? false : cart.shipping_zipcode %}

<div class="shipping-calculator" data-store="shipping-calculator">
	<div class="js-shipping-calculator-head form-swap {% if cart_zipcode %}with-zip{% else %}with-form{% endif %} {% if free_shipping_messages_visible %}with-free-shipping{% endif %}">
		<div class="js-shipping-calculator-with-zipcode{% if cart_zipcode %} js-cart-saved-zipcode{% endif %} form-swap-value transition-up{% if cart_zipcode %} transition-up-active{% endif %}">
			<div class="d-grid grid-1-auto align-items-center">
				<span class="form-swap-value-label">
					<span>{{ 'shipping.deliveries_for_zipcode' | t }}</span>
					<strong class="js-shipping-calculator-current-zip">{{ cart_zipcode }}</strong>
				</span>
				<span>
					<a class="js-shipping-calculator-change-zipcode btn btn-link font-small" href="#">{{ 'shipping.change_zipcode' | t }}</a>
				</span>
			</div>
		</div>

		<div class="js-shipping-calculator-form form-swap-input transition-up">

			{# Shipping calculator input #}

			<div class="form-label">
				{{ 'shipping.shipping_methods' | t }}
			</div>

			<div class="input-append">
				<input
					type="tel"
					name="zipcode"
					value="{{ cart_zipcode }}"
					class="js-shipping-input form-control"
					placeholder="{{ 'shipping.your_zipcode' | t }}"
					aria-label="{{ 'shipping.your_zipcode' | t }}"
				/>
				<button type="button" class="js-calculate-shipping btn btn-inline btn-outline" aria-label="{{ 'shipping.calculate_shipping' | t }}">
					<span class="js-calculate-shipping-wording">{{ 'shipping.calculate' | t }}</span>
					<span class="js-calculating-shipping-wording" style="display: none;">{{ 'cart.calculating' | t }}</span>
					<span class="loading" style="display: none;">
						{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
					</span>
				</button>
			</div>
			{% if shipping_calculator_variant %}
				<input type="hidden" name="variant_id" id="shipping-variant-id" value="{{ shipping_calculator_variant.id }}">
			{% endif %}

			{# Help info #}
			{% set zipcode_help_countries = ['BR', 'AR', 'MX'] %}
			{% if store.country in zipcode_help_countries %}
				{% set zipcode_help = 
					store.country == 'AR' ? 'https://www.correoargentino.com.ar/formularios/cpa' :
					store.country == 'BR' ? 'http://www.buscacep.correios.com.br/sistemas/buscacep/' :
					store.country == 'MX' ? 'https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/Descarga.aspx'
				%}
				<a class="{% if product_detail %}js-shipping-zipcode-help{% endif %} btn btn-link font-small" href="{{ zipcode_help }}" target="_blank">{{ 'shipping.dont_know_zipcode' | t }}</a>
			{% endif %}
			
			{# Alerts #}
			<div class="shipping-calculator-alerts">
				<div class="js-ship-calculator-error invalid-zipcode alert alert-danger" style="display: none;">
					
					{# Specific error message considering if store has multiple languages #}

					{% for language in languages %}
						{% if language.active %}
							{% if languages | length > 1 %}
								{% set wrong_zipcode_wording = 'shipping.for_country' | t ~ language.country_name ~ 'shipping.try_another_or' | t %}
							{% else %}
								{% set wrong_zipcode_wording = 'shipping.is_it_correct' | t %}
							{% endif %}
							{{ 'shipping.zipcode_not_found' | t | replace('{1}', wrong_zipcode_wording) }}

							{% if languages | length > 1 %}
								{% set language_modal_target = product_detail ? 'product' : 'cart' %}
								<button data-target="#modal-{{ language_modal_target }}-shipping-country" class="js-modal-open-private btn btn-link font-small">{{ 'shipping.change_delivery_country' | t }}</button>
							{% endif %}
						{% endif %}
					{% endfor %}
				</div>
				<div class="js-ship-calculator-error js-ship-calculator-common-error alert alert-danger" style="display: none;">{{ 'shipping.common_error' | t }}</div>
				<div class="js-ship-calculator-error js-ship-calculator-external-error alert alert-danger" style="display: none;">{{ 'shipping.external_error' | t }}</div>
			</div>
		</div>
	</div>
	<div class="js-shipping-calculator-spinner" style="display: none;">
		{% include "snippets/placeholders/shipping-placeholder.tpl" %}
	</div>
	<div class="js-shipping-calculator-response shipping-calculator-response {% if store.branches %}shipping-calculator-response-spaced{% endif %} {% if product_detail %}list{% else %}radio-buttons-group{% endif %}" style="display: none;"></div>
</div>

{# Shipping country modal #}

{% if languages | length > 1 %}

	{% set country_modal_id = product_detail ? 'product' : 'cart' %}

	{# country modal #}

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'modal-' ~ country_modal_id ~ '-shipping-country',
		data_component: country_modal_id ~ '-shipping-country',
		modal_footer: true,
		position: {
			appear_from: 'bottom',
		},
		layout: {
			width_mobile: 'small',
			width_desktop: 'small',
		},
		title: 'shipping.delivery_country_title' | t,
		modal_classes: {
			modal: 'js-modal-shipping-country',
			close_icon: 'icon-inline',
			footer: 'text-right',
		}
	} %}
		{% block modal_body %}
			<div class="form-group">
				<label class="form-label" for="shipping-country-select">{{ 'shipping.delivery_country' | t }}</label>
				<select class="js-country-select form-select" id="shipping-country-select" aria-label="{{ 'shipping.delivery_country' | t }}">
					{% for language in languages %}
						<option value="{{ language.country }}" data-country-url="{{ language.url }}" {% if language.active %}selected{% endif %}>{{ language.country_name }}</option>
					{% endfor %}
				</select>
				<div class="form-select-icon">
					<svg class="form-select-arrow icon-inline"><use xlink:href="#chevron-down"/></svg>
				</div>
			</div>
		{% endblock %}
		{% block modal_foot %}
			<a href="#" class="js-save-shipping-country btn btn-primary btn-medium d-inline-block">{{ 'shipping.apply' | t }}</a>
		{% endblock %}
	{% endembed %}
	
{% endif %}
