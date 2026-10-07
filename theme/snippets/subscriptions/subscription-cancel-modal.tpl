{#
  Subscription Cancel Modal
  Modal for confirming subscription cancellation with reason selection.
#}
{% if subscriber_permissions.can_cancel and subscription.is_active %}
	{% set modal_id = 'subscription-cancel-modal-' ~ subscription.id %}
	{% set reason_options = [
		'ACCUMULATED_STOCK',
		'NO_LONGER_USES_PRODUCT',
		'HIGH_PRICE',
		'DISSATISFACTION',
		'MANAGEMENT_LIMITATIONS',
		'USED_FOR_DISCOUNT',
		'OTHER',
	] %}

	<button
		type="button"
		class="js-modal-open-private subscription-cancel-modal-open btn-link"
		data-target="#{{ modal_id }}">
		{{ 'subscriptions.customer_subscriptions.cancel' | t }}
	</button>

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: modal_id,
		data_component: 'subscription-cancel-modal',
		title: 'subscriptions.customer_subscriptions.cancel_modal_title' | t,
		position: {
			appear_from: 'bottom',
		},
		layout: {
			width_mobile: 'small',
			width_desktop: 'small',
		},
		modal_classes: {
			close_icon: 'icon-inline',
		},
	} %}
		{% block modal_body %}
			<div class="form-description">
				<p>{{ 'subscriptions.customer_subscriptions.cancel_modal_message' | t }}</p>
			</div>
			<form method="POST" action="{{ store.customer_subscription_url(subscription) }}/cancel/">
				{% embed 'snippets/forms/form-select.tpl' with {
					select_label: true,
					select_label_name: 'subscriptions.customer_subscriptions.cancel_reason_label' | t,
					select_for: modal_id ~ '-reason',
					select_id: modal_id ~ '-reason',
					select_name: 'cancellation_reason_code',
					select_required: true,
				} %}
					{% block select_options %}
						<option value="" disabled selected>{{ 'subscriptions.customer_subscriptions.cancel_reason_placeholder' | t }}</option>
						{% for reason_code in reason_options %}
							<option value="{{ reason_code }}">{{ ('subscriptions.customer_subscriptions.cancel_reason_option_' ~ (reason_code | lower)) | t }}</option>
						{% endfor %}
					{% endblock %}
				{% endembed %}
				<div class="form-actions">
					<button type="button" class="js-modal-close-private btn-link" data-target="#{{ modal_id }}">
						{{ 'subscriptions.customer_subscriptions.cancel_back' | t }}
					</button>
					<button type="submit" class="btn btn-primary">
						{{ 'subscriptions.customer_subscriptions.cancel_confirm' | t }}
					</button>
				</div>
			</form>
		{% endblock %}
	{% endembed %}
{% endif %}
