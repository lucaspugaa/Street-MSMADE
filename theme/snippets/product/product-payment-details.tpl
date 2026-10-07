{# Product payments details modal #}

{% if product.installments_info_from_any_variant %}
	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'installments-modal',
		modal_footer: true,
		position: {
			appear_from: 'bottom'
		},
		layout: {
			width_desktop: 'large'
		},
		title: 'general.payment_methods' | t,
		modal_classes: {
			close_icon: 'icon-inline'
		}
	} %}
		{% block modal_body %}
			{% include 'snippets/payments/payments-details.tpl' with {
				discounts_conditional_visibility: true
			} %}
		{% endblock %}
		{% block modal_foot %}
			<button type="button" class="js-modal-close-private btn-link" data-target="#installments-modal">{{ 'product.back_to_product' | t }}</button>
		{% endblock %}
	{% endembed %}
{% endif %}
