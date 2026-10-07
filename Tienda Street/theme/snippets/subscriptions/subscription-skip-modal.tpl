{#
  Subscription Skip Modal
  Modal for confirming skipping the next subscription delivery.
#}
{% if skip_available %}
	{% set modal_id = 'subscription-skip-modal-' ~ subscription.id %}

	<button
		type="button"
		class="js-modal-open-private subscription-skip-modal-open btn-link"
		data-target="#{{ modal_id }}">
		{{ 'subscriptions.customer_subscriptions.skip' | t }}
	</button>

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: modal_id,
		data_component: 'subscription-skip-modal',
		title: 'subscriptions.customer_subscriptions.skip_modal_title' | t,
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
				<p>
					{{ 'subscriptions.customer_subscriptions.skip_modal_message' | t | replace('{1}', subscription.next_delivery_date | i18n_date('%d/%m/%Y')) | replace('{2}', skip_projected_date | i18n_date('%d/%m/%Y')) }}
				</p>
			</div>
			<form method="POST" action="{{ store.customer_subscription_url(subscription) }}/skip/">
				<div class="form-actions">
					<button type="button" class="js-modal-close-private btn-link" data-target="#{{ modal_id }}">
						{{ 'subscriptions.customer_subscriptions.skip_back' | t }}
					</button>
					<button type="submit" class="btn btn-primary">
						{{ 'subscriptions.customer_subscriptions.skip_confirm' | t }}
					</button>
				</div>
			</form>
		{% endblock %}
	{% endembed %}
{% endif %}
