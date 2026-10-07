{#
  Subscription Detail Items
  Last order items list for the subscription detail view.
#}
<div class="subscription-detail-items" data-store="account-subscription-items" data-component="account-subscription-items">
	<div class="order-items-header bottom-line d-none d-md-grid">
		<div>{{ 'order.product' | t }}</div>
		<div class="order-items-header-center">{{ 'general.price' | t }}</div>
		<div class="order-items-header-center">{{ 'general.quantity' | t }}</div>
		<div class="order-items-header-total">{{ 'general.total' | t }}</div>
	</div>
	<div class="order-detail">
		{% for item in last_order_items %}
			<div class="order-item">
				<div class="order-item-main">
					<div class="order-item-image-container">
						{{ item.featured_image | product_image_url("small") | img_tag(item.featured_image.alt, {class: 'd-block order-item-image'}) }}
					</div>
					<div class="order-item-name">
						{{ item.name }} <span class="order-items-header-center d-inline-block d-md-none">x{{ item.quantity }}</span>
					</div>
				</div>
				<div class="order-items-header-center d-none d-md-block">
					{{ item.unit_price | money }}
				</div>
				<div class="order-items-header-center d-none d-md-block">
					{{ item.quantity }}
				</div>
				<div class="order-items-header-total">
					{{ item.subtotal | money }}
				</div>
			</div>
		{% endfor %}
	</div>
</div>
