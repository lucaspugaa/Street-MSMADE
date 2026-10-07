{#
	Cart Coupon Input
	Coupon code form with apply/remove and loading states.
#}

{% set coupon = cart.coupon_code %}
{% set coupon_type = cart.coupon_type %}
{% set coupon_value = cart.coupon_discount %}
{% set has_coupon = coupon is not empty %}

<div
	class="js-accordion-private-container coupon-input accordion-item"
	data-store="coupon-input"
	data-error-text="{{ 'cart.coupon.error' | t }}"
	data-component="cart-coupon.container"
>
	<div class="accordion-item-header">
		<button
			type="button"
			class="js-accordion-private-toggle accordion-item-toggle"
			data-component="cart-coupon.toggle"
		>
			<span class="accordion-item-toggle-text label-with-icon">
				<svg class="icon-inline"><use xlink:href="#promotions"/></svg>
				{{ 'cart.coupon.label' | t }}
			</span>
			<span class="accordion-item-toggle-icon">
				<span class="js-accordion-private-toggle-inactive" style="display: none;">
					<svg class="icon-inline"><use xlink:href="#plus"/></svg>
				</span>
				<span class="js-accordion-private-toggle-active">
					<svg class="icon-inline"><use xlink:href="#minus"/></svg>
				</span>
			</span>
		</button>
	</div>

	<div class="js-coupon-body js-accordion-private-content accordion-item-body">

		{# Applied state: coupon code + remove button #}

		<div
			class="js-coupon-applied coupon-input-applied"
			{% if not has_coupon %}style="display: none;"{% endif %}
			{% if has_coupon %}data-coupon-type="{{ coupon_type }}" data-coupon-value="{{ coupon_value }}"{% endif %}
			data-component="cart-coupon.applied-container"
		>
			<div class="coupon-input-applied-row">
				<span class="js-coupon-applied-code coupon-input-code">
					<span class="js-coupon-applied-code-text">{{ coupon }}</span>
					<strong
						class="js-coupon-applied-percentage"
						data-component="cart-coupon.percentage"
						{% if not (cart.coupon and cart.coupon.isPercentageDiscount) %}style="display: none;"{% endif %}
					>{% if cart.coupon and cart.coupon.isPercentageDiscount %}: -{{ coupon_value | round }}%{% endif %}</strong>
				</span>
				<button
					type="button"
					class="js-remove-coupon coupon-input-remove btn btn-link"
					data-component="cart-coupon.remove"
				>
					<span class="js-remove-coupon-idle">{{ 'cart.coupon.remove' | t }}</span>
					<span class="js-remove-coupon-loading" style="display: none;">{{ 'cart.coupon.removing' | t }}</span>
					<span class="js-remove-coupon-spinner" style="display: none;" aria-hidden="true">
						{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
					</span>
				</button>
			</div>
		</div>

		{# Empty state: coupon input + apply button #}

		<div class="js-coupon-form coupon-input-form"{% if has_coupon %} style="display: none;"{% endif %}>
			<div class="input-append">
				<input
					type="text"
					name="coupon_code"
					class="js-coupon-input form-control"
					value=""
					autocorrect="off"
					autocapitalize="off"
					placeholder="{{ 'cart.coupon.placeholder' | t }}"
					aria-label="{{ 'cart.coupon.placeholder' | t }}"
					autocomplete="off"
					data-component="cart-coupon.input"
				/>
				<button
					type="button"
					class="js-apply-coupon btn btn-inline btn-outline"
					aria-label="{{ 'cart.coupon.apply' | t }}"
					data-component="cart-coupon.submit"
				>
					<span class="js-apply-coupon-idle">{{ 'cart.coupon.apply' | t }}</span>
					<span class="js-apply-coupon-loading" style="display: none;">{{ 'cart.coupon.applying' | t }}</span>
					<span class="js-apply-coupon-spinner" style="display: none;" aria-hidden="true">
						{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
					</span>
				</button>
			</div>
		</div>

		<div
			class="js-coupon-error coupon-input-error alert alert-danger"
			style="display: none;"
			role="alert"
			data-component="cart-coupon.error-message"
		></div>
	</div>
</div>
