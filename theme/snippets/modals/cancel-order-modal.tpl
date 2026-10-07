{% if store.buyer_can_cancel and order.cancellable %}
	{% set modal_id = 'cancel-order-modal-' ~ order.id %}
	{% set redirect_to_url = redirect_to | default(store.customer_order_url(order)) %}

	<button type="button" class="js-modal-open-private btn btn-secondary btn-medium btn-block" data-target="#cancel-order-modal-{{ order.id }}">
		{{ ('order.cancel_order_' ~ order.cancellation_type) | t }}
	</button>

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: modal_id,
		data_component: 'cancel-order-modal',
		title: ('order.cancel_confirm_title_' ~ order.cancellation_type) | t,
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
			{% if order.cancellation_type == 'review' %}
				<div class="form-description">
					<p>{{ 'order.cancel_confirm_order_review' | t | replace('{1}', order.number) }}</p>
					<p>{{ ('order.cancel_confirm_review_time_message_' ~ store.cancel_review_time_unit) | t | replace('{review_time}', store.cancel_review_time) | replace('{email}', customer.email) }}</p>
					<p><em>{{ 'order.cancel_confirm_warning_review' | t }}</em></p>
				</div>
			{% else %}
				<div class="form-description">
					<p>{{ 'order.cancel_confirm_order' | t | replace('{1}', order.number) }}</p>
					<p>{{ 'order.cancel_confirm_refund' | t | replace('%%amount%%', order.total | money) }}</p>
					<p>{{ 'order.cancel_confirm_warning' | t }}</p>
				</div>
			{% endif %}
			<form method="POST" action="/account/cancel_request/{{ order.id }}/" class="cancel-order-form">
				<input type="hidden" name="redirect_to" value="{{ redirect_to_url }}">
				<input type="hidden" name="origin_layer" value="{{ order.available_layer }}">
				{% set reason_options = ['buyer_regret', 'payment_change', 'shipping_method_change', 'shipping_address_change', 'order_change', 'discount_use', 'other'] %}
				{% embed 'snippets/forms/form-select.tpl' with {
					select_label: true,
					select_label_name: 'order.cancel_confirm_reason_label' | t,
					select_for: modal_id ~ '-reason',
					select_id: modal_id ~ '-reason',
					select_name: 'reason',
					select_required: true,
				} %}
					{% block select_options %}
						<option value="" disabled selected>{{ 'order.cancel_confirm_reason_placeholder' | t }}</option>
						{% for reason_code in reason_options %}
							<option value="{{ reason_code }}">{{ ('order.cancel_confirm_reason_' ~ reason_code) | t }}</option>
						{% endfor %}
					{% endblock %}
				{% endembed %}
				<div class="form-actions">
					<button type="button" class="js-modal-close-private btn-link" data-target="#{{ modal_id }}">
						{{ 'order.cancel_confirm_back' | t }}
					</button>
					<button type="submit" class="btn btn-primary">
						{{ ('order.cancel_confirm_submit_' ~ order.cancellation_type) | t }}
					</button>
				</div>
			</form>
		{% endblock %}
	{% endembed %}
{% endif %}
