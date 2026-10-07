{#
  Subscription Detail
  Complete subscription detail view with info and items sections.
#}
{% set subscription_action_success_keys = {
	'skip': 'subscriptions.customer_subscriptions.skip_success',
	'address': 'subscriptions.customer_subscriptions.address_success',
	'cancel': 'subscriptions.customer_subscriptions.cancel_success',
} %}
{% set subscription_action_success_key = subscription_action_success_keys[subscription_action_success] ?? null %}
{% if subscription_action_success_key %}
	<div class="alert alert-success" role="alert">
		{{ subscription_action_success_key | t }}
	</div>
{% elseif subscription_action_error %}
	<div class="alert alert-danger" role="alert">
		{{ 'subscriptions.customer_subscriptions.action_error' | t }}
	</div>
{% endif %}
<div class="account-page-content">
	{% include 'snippets/subscriptions/subscription-detail-info.tpl' %}
	{% if last_order_items %}
		<div class="order-detail-items-container">
			{% include 'snippets/subscriptions/subscription-detail-items.tpl' %}
		</div>
	{% endif %}
</div>
