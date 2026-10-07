{#
  Subscription List
  List of a customer's active and cancelled subscriptions.
#}
{% if subscriptions %}
	<div class="account-subscriptions-list" data-store="account-subscriptions">
		<div class="account-orders-heading">
			{{ 'subscriptions.customer_subscriptions.my_subscriptions' | t }}
		</div>
		<div class="account-orders-grid">
			{% for subscription in subscriptions %}
				{% set show_tracking = subscription.is_active and subscription.last_order and subscription.last_order.order_status_url != null %}
				<div class="account-order-card" data-store="account-subscription-item-{{ subscription.id }}">
					{% embed "snippets/card.tpl" with { card_footer: show_tracking, card_custom_class: 'card-collapse', card_collapse: true } %}
						{% block card_head %}
							<div class="account-order-header-content">
								<div class="account-order-number">
									<a class="btn-link" href="{{ store.customer_subscription_url(subscription) }}"><strong>{{ subscription.id }}</strong></a>
								</div>
								<div class="js-card-collapse-toggle account-order-date">
									<span class="label {% if subscription.is_active %}label-success{% else %}label-default{% endif %}">
										{{ (subscription.is_active ? 'subscriptions.customer_subscriptions.active' : 'subscriptions.customer_subscriptions.cancelled') | t }}
									</span>
								</div>
							</div>
						{% endblock %}
						{% block card_body %}
							<div class="account-order-body">
								<div class="account-order-status-container">
									{% if subscription.last_order %}
										<div class="order-detail-line">
											<svg class="order-detail-icon icon-inline"><use xlink:href="#calendar"/></svg>
											{{ 'subscriptions.customer_subscriptions.last_order' | t }}: <strong>{{ subscription.last_order.date | i18n_date('%d/%m/%Y') }}</strong>
										</div>
										<div class="order-detail-line">
											<svg class="order-detail-icon icon-inline"><use xlink:href="#truck"/></svg>
											{{ 'subscriptions.customer_subscriptions.shipping' | t }}: <strong>{{ (subscription.last_order.shipping_status == 'fulfilled' ? 'subscriptions.customer_subscriptions.shipped' : 'subscriptions.customer_subscriptions.not_shipped') | t }}</strong>
										</div>
									{% endif %}
									{% if subscription.is_active and subscription.next_delivery_date %}
										<div class="order-detail-line">
											<svg class="order-detail-icon icon-inline"><use xlink:href="#calendar"/></svg>
											{{ 'subscriptions.customer_subscriptions.next_order' | t }}: <strong>{{ subscription.next_delivery_date | i18n_date('%d/%m/%Y') }}</strong>
										</div>
									{% endif %}
									<a class="account-order-detail-link btn-link" href="{{ store.customer_subscription_url(subscription) }}">{{ 'subscriptions.customer_subscriptions.view_detail' | t }}</a>
								</div>
								{% if subscription.last_order %}
									<div class="order-item-image-container">
										{% for line_item in subscription.last_order.items %}
											{% if loop.first %}
												{{ line_item.featured_image | product_image_url("") | img_tag(line_item.featured_image.alt, {class: 'order-item-image'}) }}
											{% endif %}
										{% endfor %}
									</div>
								{% endif %}
							</div>
						{% endblock %}
						{% block card_foot %}
							{% if show_tracking %}
								<a class="btn btn-primary btn-medium d-block" href="{{ subscription.last_order.order_status_url | add_param('ref', 'orders_list') }}" target="_blank">{{ 'subscriptions.customer_subscriptions.track_order' | t }}</a>
							{% endif %}
						{% endblock %}
					{% endembed %}
				</div>
			{% endfor %}
		</div>
	</div>
{% endif %}
