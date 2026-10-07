{# Installments
 Installment payment info for product detail, product item, and cart.
 #}

{% if location == 'cart' %}
	{% if cart.installments.max_installments_without_interest > 1 %}
		{% set installment_amount =  cart.installments.max_installments_without_interest  %}
		{% set total_installment = cart.total %}
		{% set has_no_interest_payments = true %}
		{% set interest_value = 0 %}
	{% else %}
		{% set installment_amount = cart.installments.max_installments_with_interest  %}
		{% set total_installment = (cart.total * (1 + cart.installments.interest)) %}
		{% set has_no_interest_payments = false %}
		{% set interest_value = cart.installments.interest %}
	{% endif %}
	  <div {% if installment_amount < 2 or ( store.country == 'AR' and not has_no_interest_payments ) %} style="display: none;" {% endif %} data-interest="{{ interest_value }}" data-cart-installment="{{ installment_amount }}" class="js-installments-cart-total cart-installments {{ container_classes.installment }} {% if has_no_interest_payments %}installment-no-interest{% endif %}">
		{{ 'installments.up_to' | t }}

		<span class='js-cart-installments-amount cart-installments-amount {% if has_no_interest_payments %}installment-no-interest{% endif %}'>{{ installment_amount }}</span>

		{# Main wording #}

		<span>
			{% if short_wording %}
				<span class="installment-short-separator">
					{{ 'installments.installment_shortened' | t }}
				</span>
			{% else %}
				{{ 'installments.installment' | t }}
				{% if has_no_interest_payments and store.country != 'BR' %}
					{{ 'installments.no_interest' | t }}
				{% endif %}
			{% endif %}

			{% if not short_wording or store.country == 'BR' %}
				{{ 'installments.of' | t }}
			{% endif %}
		</span>

		{# Installment value #}

		<span class='js-cart-installments cart-installments-money {% if has_no_interest_payments %}installment-no-interest{% endif %}'>{{ (total_installment / installment_amount) | money }}</span>

		{% if has_no_interest_payments and ((short_wording and store.country != 'BR') or store.country == 'BR') %}
			<span>
				{{ 'installments.no_interest' | t }}
			</span>
		{% endif %}
	  </div>
{% endif %}
{% if location == 'product_detail' or location == 'product_item' %}

	{% set product_can_show_installments = product.show_installments and product.display_price and product.get_max_installments.installment > 1 %}

	{% if product_can_show_installments %}

		{% set max_installments_without_interests = product.get_max_installments(false) %}
		{% set max_installments_with_interests = product.get_max_installments %}

		{% set has_no_interest_payments = max_installments_without_interests and max_installments_without_interests.installment > 1 %}

		{#
			NOTE: Subscription only products should not display installments since installment payments
			do not apply to subscription purchases.
			Related file: stores/application/views/our/components/subscriptions/subscription-price.tpl (with location: 'product_list')
		#}
		{% set is_subscription_only = product.isSubscriptionOnly is defined and product.isSubscriptionOnly() %}
		{% if not hidden_product_installments and not is_subscription_only %}
			<div class="js-max-installments-container js-max-installments {{ container_classes.installment }}">

				{# No interest installment #}

				{% if has_no_interest_payments %}
					<div class="js-max-installments product-installments installment-no-interest">

						{# Set installment amount and value #}

						{% set installment_amount = max_installments_without_interests.installment %}
						{% set installment_value = max_installments_without_interests.installment_data.installment_value_cents | money %}

						{# Installment amount #}

						<span class='js-installment-amount product-installment-amount'>{{ installment_amount }}</span>

						{# Main wording #}

						<span>
							{% if short_wording %}
								<span class="installment-short-separator">
									{{ 'installments.installment_shortened' | t }}
								</span>
							{% else %}
								{{ 'installments.installment' | t }}
								{% if store.country != 'BR' %}
									{{ 'installments.no_interest' | t }}
								{% endif %}
							{% endif %}

							{% if not short_wording or store.country == 'BR' %}
								{{ 'installments.of' | t }}
							{% endif %}
						</span>

						{# Installment value #}

						<span class='js-installment-price product-installment-value'>{{ installment_value }}</span>

						{# No interest wording #}

						{% if (short_wording and store.country != 'BR') or store.country == 'BR' %}
							<span>
								{{ 'installments.no_interest' | t }}
							</span>
						{% endif %}
					</div>
				{% else %}

					{# With interest installment #}

					{% if store.country != 'AR' or location == 'product_detail' %}
						<div class="js-max-installments product-installments">

							{% if max_installments_with_interests %}

								{# Set installment amount and value #}

								{% set installment_amount = max_installments_with_interests.installment %}
								{% set installment_value = max_installments_with_interests.installment_data.installment_value_cents | money %}
								{% set max_installment_is_third_party_collector = max_installments_with_interests.installment_data.collector_is_third_party %}

								{# Installment amount #}

								<span class='js-installment-amount product-installment-amount'>{{ installment_amount }}</span>

								{# Main wording #}

								<span>
									{% if short_wording %}
										<span class="installment-short-separator">
											{{ 'installments.installment_shortened' | t }}
										</span>
									{% else %}
										{{ 'installments.installment' | t }}
									{% endif %}

									{% if not short_wording or store.country == 'BR' %}
										{{ 'installments.of' | t }}
									{% endif %}
								</span>

								{# Installment value #}

								<span class='js-installment-price product-installment-value'>
									{{ installment_value }}
									{% if max_installment_is_third_party_collector %}
										{{ 'installments.third_party_collector' | t }}
									{% endif %}
								</span>
							{% else %}

								{# TODO: Analyze if this whole part is neccesary #}

								<div class="js-max-installments product-installments" style="display: none;">

									{# Set installment amount and value #}

									{% set installment_amount = null %}
									{% set installment_value = null %}

									{# Installment amount #}

									<span class='js-installment-amount product-installment-amount'>{{ installment_amount }}</span>

									{# Main wording #}

									<span>
										{% if short_wording %}
											<span class="installment-short-separator">
												{{ 'installments.installment_shortened' | t }}
											</span>
										{% else %}
											{{ 'installments.installment' | t }}
											{% if has_no_interest_payments and store.country != 'BR' %}
												{{ 'installments.no_interest' | t }}
											{% endif %}
										{% endif %}

										{% if not short_wording or store.country == 'BR' %}
											{{ 'installments.of' | t }}
										{% endif %}
									</span>

									{# Installment value #}

									<span class='js-installment-price product-installment-value'>{{ installment_value }}</span>

									{# No interest wording #}

									{% if has_no_interest_payments and ((short_wording and store.country != 'BR') or store.country == 'BR') %}
										<span>
											{{ 'installments.no_interest' | t }}
										</span>
									{% endif %}
								</div>
							{% endif %}
						</div>
					{% endif %}
				{% endif %}
			</div>
		{% endif %}
	{% endif %}
{% endif %}
