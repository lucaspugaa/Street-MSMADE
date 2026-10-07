{% set cart_button = cart_button ?? true %}
{% set modal_dismiss = modal_dismiss ?? true %}

{# Cookie validation notification #}

{% if type == 'cookies' and not params.preview and not should_omit_consent_management %}
	<div class="js-notification-private js-notification-cookie-private notification notification-fixed notification-fixed-bottom" style="display: none;">
		<span class="notification-message">{{ 'notification.cookies_message' | t | raw }}</span>
		<button class="js-notification-close-private js-acknowledge-cookies-private notification-accept-btn notification-link btn-link" data-amplitude-event-name="cookie_banner_acknowledge_click">{{ 'notification.cookies_accept' | t }}</button>
	</div>
{% endif %}

{# Follow last order notification #}

{% if type == 'order' and status_page_url_notification %}
	<div class="js-notification-private js-notification-status-page-private notification-order notification notification-fixed notification-fixed-md-right" style="display:none;" data-url="{{ status_page_url_notification }}">
		<div class="notification-content-wrapper">
			<a href="{{ status_page_url_notification }}" class="notification-link btn-link">
				{{ 'notification.order_link' | t }}
			</a>
			<span class="notification-message">{{ 'notification.order_message' | t }}</span>
		</div>
		<button class="js-notification-close-private js-notification-status-page-close-private notification-close">
			<svg class="notification-close-icon icon-inline"><use xlink:href="#times"/></svg>
		</button>
	</div>
{% endif %}

{# Add to cart notification #}

{% if type == 'add_to_cart' %}
	{% set cart_item_classes = 'd-grid grid-auto-1' %}
	{% set cart_image_container_classes = 'mr-3' %}
	{% set cart_image_classes = 'img-absolute-centered-vertically' %}

	{% if related_products %}
		<div class="js-alert-add-to-cart-private d-md-grid grid-1-auto">
			<div class="notification-cart-inline notification">
	{% else %}
		<div class="js-alert-add-to-cart-private js-notification-cart notification-cart-container notification-hidden" style="display: none;">
			<div class="notification">
				<button class="js-cart-notification-close-private notification-close">
					<svg class="notification-close-icon icon-inline"><use xlink:href="#times"/></svg>
				</button>
	{% endif %}
			<div class="js-cart-notification-item-private notification-cart-item {{ cart_item_classes }}" data-store="cart-notification-item">
				<div class="notification-cart-image-container {{ cart_image_container_classes }}">
					{% include 'snippets/image.tpl' with {
						image_classes: 'js-cart-notification-item-image-private notification-cart-image ' ~ cart_image_classes,
						image_lazy_js: true,
						image_thumbs: false,
					} %}
				</div>
				<div class="notification-info-container {{ related_products ? 'notification-info-compact' }}">
					<div class="notification-info-line">
						<span class="js-cart-notification-item-name-private"></span>
						<span class="js-cart-notification-item-variant-container-private" style="display: none;">
							(<span class="js-cart-notification-item-variant-private"></span>)
						</span>
					</div>
					<div class="notification-info-line">
						<span>
							<span class="js-cart-notification-item-quantity-private"></span>
							<span> x </span>
						</span>
						<span class="js-cart-notification-item-price-private"></span>
						<span class="js-cart-notification-discount-label notification-cart-discount-label" style="display: none;">
							<span class="js-cart-notification-discount-percentage notification-cart-discount-badge"></span>
						</span>
					</div>
					{% if not related_products %}
						<div class="notification-cart-success">{{ 'notification.add_to_cart_success' | t }}</div>
					{% endif %}
				</div>
			</div>
		</div>
		{% if related_products %}
			<div>
				<div class="notification-cart-total">
					<span class="pr-3">
						<span>{{ 'general.total' | t }}</span>
						(<span class="js-cart-widget-amount">
							{{ cart.items_count }}
						</span>
						<span class="js-cart-counts-plural-private" style="display: none;">
							{{ 'notification.product_plural' | t | lower }}
						</span>
						<span class="js-cart-counts-singular-private" style="display: none;">
							{{ 'notification.product_singular' | t | lower }}
						</span>)
					</span>
					<span class="js-cart-total-private js-cart-widget-total">{{ cart.total | money }}</span>
				</div>
				{% if cart_button %}
					{% set cart_button_wording = 'notification.cart_button' | t %}

				{% if modal_dismiss %}
					<button data-target="#related-products-notification" class="js-modal-close-private js-open-cart-modal btn btn-primary btn-block">{{ cart_button_wording }}</button>
					{% else %}
						<a href="{{ store.cart_url }}" class="js-open-cart-modal btn btn-primary btn-block">{{ cart_button_wording }}</a>
					{% endif %}
				{% endif %}
			</div>
		{% endif %}
	</div>
{% endif %}
