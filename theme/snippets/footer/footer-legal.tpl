
{% set show_payments = section.settings.footer_payments_show is defined ? section.settings.footer_payments_show : true %}
{% set show_shipping = section.settings.footer_shipping_show is defined ? section.settings.footer_shipping_show : true %}
{% set has_payment_logos = settings.payments and show_payments %}
{% set has_shipping_logos = settings.shipping and show_shipping %}
{% set has_shipping_payment_logos = (has_payment_logos or has_shipping_logos) and not password_page %}
{% set has_seal_logos = store.afip or ebit or section.settings.footer_custom_seal_code or section.settings.footer_seal_img %}

{% if has_shipping_payment_logos %}
	<div class="footer-payments-shipping-container">
		{% set payment_shipping_title_classes = 'footer-payment-shipping-label' %}

		{% if has_payment_logos %}
			<div class="footer-payment-group">
				<span class="{{ payment_shipping_title_classes }}">{{ 'general.payment_methods' | t }}</span>
			<span class="footer-logos-wrapper">
				{% include 'snippets/footer/payment-shipping-logos.tpl' with {'type' : 'payments'} %}
			</span>
		</div>
	{% endif %}

	{% if has_shipping_logos %}
		<div class="footer-payment-group">
			<span class="{{ payment_shipping_title_classes }}">{{ 'general.shipping_methods_label' | t }}</span>
			<span class="footer-logos-wrapper">
				{% include 'snippets/footer/payment-shipping-logos.tpl' with {'type' : 'shipping'} %}
			</span>
			</div>
		{% endif %}
	</div>
{% endif %}

<div class="footer-legal-container">
	{% if has_seal_logos %}
		<div class="footer-seals-container">
				{% if store.afip or ebit %}
					{% if store.afip %}
						<div class="footer-logo afip seal-afip">
							{{ store.afip | raw }}
						</div>
					{% endif %}
					{% if ebit %}
						<div class="footer-logo ebit seal-ebit">
							{{ ebit }}
						</div>
					{% endif %}
				{% endif %}
			{% if section.settings.footer_seal_img or section.settings.footer_custom_seal_code %}
				{% if section.settings.footer_seal_img %}
					<div class="footer-logo custom-seal">
						{% if section.settings.footer_seal_url %}
							<a href="{{ section.settings.footer_seal_url }}" target="_blank" rel="noopener noreferrer">
						{% endif %}
						{% include 'snippets/image.tpl' with {
							image_src: section.settings.footer_seal_img,
							image_lazy_js: true,
							image_classes: 'custom-seal-img fade-in',
							image_alt: 'general.seal_of' | t ~ ' ' ~ store.name,
						} %}
						{% if section.settings.footer_seal_url %}
							</a>
						{% endif %}
					</div>
				{% endif %}
				{% if section.settings.footer_custom_seal_code %}
					<div class="custom-seal custom-seal-code">
						{{ section.settings.footer_custom_seal_code | raw }}
					</div>
				{% endif %}
			{% endif %}

			{{ component('nubesdk-slot', { type: "footer_seals" }) }}

		</div>
	{% endif %}

	{{ component('nubesdk-slot', { type: "inside_footer" }) }}

	<div>
		{% include 'snippets/footer/claim-info.tpl' %}
		<div>
			<span class="footer-powered-by">
				{{ new_powered_by_link }}
			</span>
			<span class="footer-copyright">
				{{ 'general.copyright' | t | replace('{1}', (store.business_name ? store.business_name : store.name) ~ (store.business_id ? ' - ' ~ store.business_id)) | replace('{2}', "now" | date('Y')) }}
			</span>
		</div>
	</div>
</div>
