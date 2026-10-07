{#
  Subscription Detail Info
  Subscription info panel with status, frequency, next order, payment, and address.
#}
<div class="order-detail-info" data-store="account-subscription-info" data-component="account-subscription-info">
	<div class="account-section-header">
		<h6 class="account-section-title">{{ 'subscriptions.customer_subscriptions.about_subscription' | t }}</h6>
		{% include 'snippets/subscriptions/subscription-cancel-modal.tpl' %}
	</div>
	<div class="order-detail-line">
		<svg class="order-detail-icon icon-inline"><use xlink:href="#info"/></svg>
		{{ 'subscriptions.customer_subscriptions.status' | t }}: <strong>{{ subscription.is_active ? ('subscriptions.customer_subscriptions.active' | t) : ('subscriptions.customer_subscriptions.cancelled' | t) }}</strong>
	</div>
	{% if subscription.frequency_param %}
		<div class="order-detail-line">
			<svg class="order-detail-icon icon-inline"><use xlink:href="#calendar"/></svg>
			{{ 'subscriptions.customer_subscriptions.frequency' | t }}: <strong>{{ 'subscriptions.customer_subscriptions.frequency_every_n_days' | t | replace('{1}', subscription.frequency_param) }}</strong>
		</div>
	{% endif %}
	{% if subscription.discount_percentage %}
		<div class="order-detail-line">
			<svg class="order-detail-icon icon-inline"><use xlink:href="#promotions"/></svg>
			{{ 'subscriptions.customer_subscriptions.discount' | t }}: <strong>{{ subscription.discount_percentage }}%</strong>
		</div>
	{% endif %}
	{% if subscription.is_active %}
		<div class="account-section-header">
			<h6 class="account-section-title">{{ 'subscriptions.customer_subscriptions.next_order_title' | t }}</h6>
			{% include 'snippets/subscriptions/subscription-skip-modal.tpl' %}
		</div>
		{% if subscription.next_delivery_date %}
			<div class="order-detail-line">
				<svg class="order-detail-icon icon-inline"><use xlink:href="#calendar"/></svg>
				{{ 'subscriptions.customer_subscriptions.next_order' | t }}: <strong>{{ subscription.next_delivery_date | i18n_date('%d/%m/%Y') }}</strong>
			</div>
		{% endif %}
		{% if subscription.payment_brand and subscription.payment_last_four %}
			<div class="order-detail-line">
				<svg class="order-detail-icon icon-inline"><use xlink:href="#credit-card"/></svg>
				{{ 'subscriptions.customer_subscriptions.payment_method' | t }}: <strong>{{ subscription.payment_brand | capitalize }} •••• {{ subscription.payment_last_four }}</strong>
			</div>
		{% endif %}
	{% endif %}
	{% if subscription.shipping_address %}
		{% set address = subscription.shipping_address %}
		<div class="account-section-header">
			<h6 class="account-section-title">{{ 'subscriptions.customer_subscriptions.shipping_address' | t }}</h6>
			{% if subscriber_permissions.can_change_shipping_address and subscription.is_active %}
				<a class="btn-link" href="{{ store.customer_subscription_url(subscription) }}/address/">
					{{ 'subscriptions.customer_subscriptions.change' | t }}
				</a>
			{% endif %}
		</div>
		<div class="order-detail-line">
			<div>{{ address.first_name }} {{ address.last_name }}</div>
			<div>{{ address.address }} {{ address.number }}{% if address.floor %}, {{ address.floor }}{% endif %}</div>
			<div>{{ address.city }}{% if address.state %}, {{ address.state }}{% endif %} {{ address.zipcode }}</div>
			{% if address.country %}
				<div>{{ address.country }}</div>
			{% endif %}
			{% if address.phone %}
				<div>{{ address.phone }}</div>
			{% endif %}
		</div>
	{% endif %}
</div>
