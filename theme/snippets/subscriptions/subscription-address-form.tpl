{#
  Subscription Address Form
  Form for updating the shipping address of a subscription.
#}
{% set address = subscription.shipping_address %}
<div class="subscription-address-form" data-store="account-subscription-address" data-component="account-subscription-address">
	{% if result.errors is not empty %}
		<div class="alert alert-danger">
			{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}
		</div>
	{% endif %}
	<div class="alert alert-info">
		{{ 'subscriptions.customer_subscriptions.address_notice' | t }}
	</div>
	<form method="POST" action="{{ store.customer_subscription_url(subscription) }}/address/">
		{% embed 'snippets/forms/form-input.tpl' with {
			type_tel: true,
			input_for: 'zipcode',
			input_name: 'zipcode',
			input_id: 'zipcode',
			input_label_text: 'subscriptions.customer_subscriptions.address_zipcode' | t,
			input_value: result.zipcode | default(address.zipcode),
		} %}
			{% block input_form_alert %}
				{% if result.errors.zipcode %}
					<div class="notification-danger notification-left">{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}</div>
				{% endif %}
			{% endblock %}
		{% endembed %}
		<div class="grid grid-2">
			{% embed 'snippets/forms/form-input.tpl' with {
				type_text: true,
				input_for: 'address',
				input_name: 'address',
				input_id: 'address',
				input_label_text: 'subscriptions.customer_subscriptions.address_street' | t,
				input_value: result.address | default(address.address),
			} %}
				{% block input_form_alert %}
					{% if result.errors.address %}
						<div class="notification-danger notification-left">{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}</div>
					{% endif %}
				{% endblock %}
			{% endembed %}
			{% embed 'snippets/forms/form-input.tpl' with {
				type_text: true,
				input_for: 'number',
				input_name: 'number',
				input_id: 'number',
				input_label_text: 'subscriptions.customer_subscriptions.address_number' | t,
				input_value: result.number | default(address.number),
			} %}
				{% block input_form_alert %}
					{% if result.errors.number %}
						<div class="notification-danger notification-left">{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}</div>
					{% endif %}
				{% endblock %}
			{% endembed %}
		</div>
		{% embed 'snippets/forms/form-input.tpl' with {
			type_text: true,
			input_for: 'locality',
			input_name: 'locality',
			input_id: 'locality',
			input_label_text: 'subscriptions.customer_subscriptions.address_locality' | t,
			input_value: result.locality | default(address.locality),
			input_placeholder: 'subscriptions.customer_subscriptions.address_optional' | t,
		} %}{% endembed %}
		<div class="grid grid-2">
			{% embed 'snippets/forms/form-input.tpl' with {
				type_text: true,
				input_for: 'city',
				input_name: 'city',
				input_id: 'city',
				input_label_text: 'subscriptions.customer_subscriptions.address_city' | t,
				input_value: result.city | default(address.city),
			} %}
				{% block input_form_alert %}
					{% if result.errors.city %}
						<div class="notification-danger notification-left">{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}</div>
					{% endif %}
				{% endblock %}
			{% endembed %}
			{% embed 'snippets/forms/form-input.tpl' with {
				type_text: true,
				input_for: 'state',
				input_name: 'state',
				input_id: 'state',
				input_label_text: 'subscriptions.customer_subscriptions.address_state' | t,
				input_value: result.state | default(address.state),
			} %}
				{% block input_form_alert %}
					{% if result.errors.state %}
						<div class="notification-danger notification-left">{{ 'subscriptions.customer_subscriptions.address_field_required' | t }}</div>
					{% endif %}
				{% endblock %}
			{% endembed %}
		</div>
		{% embed 'snippets/forms/form-input.tpl' with {
			type_text: true,
			input_for: 'floor',
			input_name: 'floor',
			input_id: 'floor',
			input_label_text: 'subscriptions.customer_subscriptions.address_floor' | t,
			input_value: result.floor | default(address.floor),
			input_placeholder: 'subscriptions.customer_subscriptions.address_optional' | t,
		} %}{% endembed %}
		<div class="form-actions">
			<button type="submit" class="btn btn-primary btn-block">
				{{ 'subscriptions.customer_subscriptions.address_save' | t }}
			</button>
		</div>
	</form>
</div>
