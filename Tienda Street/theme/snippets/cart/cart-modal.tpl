{# Cart modal - Ajax cart panel #}

{% if not store.is_catalog and settings.ajax_cart and template != 'cart' %}

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'modal-cart',
		data_component: 'cart',
		custom_data_attribute: 'cart-open-type',
		custom_data_attribute_value: settings.cart_open_type,
		form: true,
		form_action: store.cart_url,
		form_data_store: 'cart-form',
		position: {
			dock_desktop: true,
			appear_from: 'right',
		},
		layout: {
			width_desktop: 'small',
		},
		title: 'cart.title' | t,
		modal_classes: {
			close_icon: 'icon-inline',
		}
	} %}
		{% block modal_body %}
			{% include 'snippets/cart/cart-panel.tpl' %}
		{% endblock %}
	{% endembed %}

	{% if settings.add_to_cart_recommendations %}

		{# Recommended products on add to cart #}

		{% embed 'snippets/modals/modal.tpl' with {
			modal_id: 'related-products-notification',
			position: {
				appear_from: 'bottom',
			},
			layout: {
				width_desktop: 'medium',
			},
			title: 'cart.added_to_cart' | t,
			modal_classes: {
				modal: 'h-auto',
				close_icon: 'icon-inline',
			}
		} %}
			{% block modal_body %}
				{% include 'snippets/notification.tpl' with {
						type: 'add_to_cart',
						related_products: true,
					} %}
				<div class="js-related-products-notification-container" style="display: none"></div>
			{% endblock %}
		{% endembed %}
	{% endif %}

	{# Cross selling promotion notification on add to cart #}

	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'js-cross-selling-modal',
		position: {
			appear_from: 'bottom',
		},
		title: 'cart.exclusive_discount' | t,
		layout: {
			width_desktop: 'small'
		},
		modal_classes: {
			modal: 'modal-nav-main bottom modal-bottom-sheet h-auto overflow-none modal-body-scrollable-auto modal-max-98vh',
			header: 'p-quarter full-width',
			close_icon: 'icon-inline',
		}
	} %}
		{% block modal_body %}
			<div class="js-cross-selling-modal-body" style="display: none"></div>
		{% endblock %}
	{% endembed %}
{% endif %}
