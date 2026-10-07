{#
  Subscription Summary
  Brief subscription information shown within an order detail view.
#}
<div data-store="account-subscription-summary" data-component="account-subscription-summary">
	<div class="order-detail-line">
		<strong>{{ 'subscriptions.customer_subscriptions.subscription' | t }}</strong>
	</div>
	<div class="order-detail-line">
		{{ 'subscriptions.customer_subscriptions.subscription_id' | t }}: <a href="{{ store.customer_subscription_url(order_subscription) }}">{{ order_subscription.id }}</a>
	</div>
	{% if order_subscription.frequency_param %}
		<div class="order-detail-line">
			{{ 'subscriptions.customer_subscriptions.shipping_every' | t }}: <strong>{{ 'subscriptions.customer_subscriptions.n_days' | t | replace('{1}', order_subscription.frequency_param) }}</strong>
		</div>
	{% endif %}
	{% if order_subscription.discount_percentage %}
		<div class="order-detail-line">
			{{ 'subscriptions.customer_subscriptions.applied_discount' | t }}: <strong>{{ order_subscription.discount_percentage }}%</strong>
		</div>
	{% endif %}
</div>
