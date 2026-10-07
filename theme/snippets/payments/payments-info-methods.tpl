{# Payments Info Methods
 Supported payment methods with installment details and discount info.
 #}

{% for paymentMethod in paymentProvider.supported_payment_methods %}
    {% set hasDiscount = paymentMethod.discount > 0 %}
    {% set hasInstallments = paymentMethod.installmentGroups is not empty %}
    {% set hasMinimumInstallmentValue = paymentProvider.minimum_installment_value is not empty ? paymentProvider.minimum_installment_value * 100 %}
    {% set showDiscount = hasDiscount and product.showDiscountForPaymentMethod(paymentMethod) %}
    {% set discountStyle = (not showDiscount and discounts_conditional_visibility) or not hasDiscount ? 'display: none' %}


    {# Payment Method Title #}
    <div class="js-payment-method-title js-payment-method-title-{{ paymentMethod.id }} payments-section-title">{{ paymentMethod.name }}</div>

    {% set info_payment_method_classes = "js-info-payment-method-container payments-card card" %}
    <div id="info-payment-method-{{ paymentMethod.id }}" {% if hasInstallments and hasMinimumInstallmentValue %} class="js-info-payment-method js-payment-method-{{ paymentMethod.id }} {{ info_payment_method_classes }}" data-minimum-installment-value="{{ paymentProvider.minimum_installment_value }}"{% else %}class="{{ info_payment_method_classes }}"{% endif %}>
        {# Payment Method Logos #}
        {% if paymentMethod.logos is not empty %}
            <div class="payments-logos">
                {% for logo in paymentMethod.logos %}
                    {% include 'snippets/image.tpl' with {
                        image_src: logo | payment_new_logo,
                        image_alt: paymentMethod.name,
                        image_classes: 'card-img card-img-medium',
                        image_lazy_js: true,
                        image_thumbs: false,
                    } %}
                {% endfor %}
            </div>
        {% endif %}

        {# Payment Method Discount #}
        {% set method_discount = payment_methods_config[method].payment_method_discounts[paymentMethod.id] ?? null %}
        {% set max_installments = method_discount ? method_discount.max_installments : null %}
        <div class="js-payment-method-discount payments-method-discount" style="{{discountStyle}}">
            <span><strong>{{ paymentMethod.discount }}% {{ 'payments.off_discount' | t }}</strong> {{ 'payments.paying_with' | t }} {{ paymentMethod.name }}
                {% if max_installments and paymentMethod.id == 'credit_card' %}
                    <span class="js-payment-discount-installments">{{ (max_installments == 1 ? 'product.in_installments_singular' : 'product.in_installments_plural') | t(max_installments) }}</span>
                {% endif %}
            </span>
        </div>

        {# Payment Method Total #}
        <div class="js-payment-method-total">
            <span class="payments-installment-highlight">
                {% if hasInstallments %}
                    <span>{{ 'payments.total_one_payment' | t }}: </span>
                {% else %}
                    <span>{{ 'payments.total' | t }}: </span>
                {% endif %}

                <span style="{{ discountStyle }}" class="js-installments-one-payment js-compare-price-display price-compare">{{ product.price | money }}</span>
                <strong style="{{ discountStyle }}" class="js-price-with-discount" data-payment-discount="{{ paymentMethod.discount }}">{{ paymentMethod.priceWithDiscount | money }}</strong>

                {% set installmentsOnePaymentStyle = showDiscount or (not discounts_conditional_visibility and hasDiscount) ? 'display: none' %}
                <strong class="js-installments-one-payment js-installments-no-discount" style="{{ installmentsOnePaymentStyle }}">{{ product.price | money }}</strong>
            </span>
            {% if hasInstallments and paymentMethod.isCardType %}
                <span class="payments-additional-info">{{ 'payments.with_all_cards' | t }}</span>
            {% endif %}
        </div>

        <div class="js-discount-explanation payments-explanation" style="{{discountStyle}}">{{ 'payments.discount_explanation' | t }}</div>

        {% set showDisclaimer = showDiscount and product.showDiscountNotCombinableDisclaimer(paymentMethod) %}
        {% set discountDisclaimerStyle = (not showDisclaimer or not discounts_conditional_visibility) ? 'display: none'  %}

        <div class="js-discount-disclaimer payments-disclaimer" style="{{ discountDisclaimerStyle }}">
            {{ ( product.showCombinesWithSomeDiscountsDisclaimer(paymentMethod)
                ? 'payments.not_combinable_with_some'
                : 'payments.non_combinable_discount')
            | t }}
        </div>

        {# Installments List #}
        {% if hasInstallments %}
            <div class="js-payment-method-installments-table-title payments-installments-title">
                <strong>{{ 'payments.or_pay_in' | t }}</strong>
            </div>

            {% for installmentGroup in paymentMethod.installmentGroups %}
                {# Installment Specification #}
                <table class="js-payments-table payments-table table">
                    <tbody>
                        {% for installment in installmentGroup.installments %}
                            <tr id="installment_{{ paymentProvider.id | replace(' ', '_') }}_{{ installment.quantity }}" class="js-payment-provider-installments-row"{% if hasMinimumInstallmentValue > installment.amountInCents %} style="display:none;"{% endif %}>
                                {# Installment Info #}
                                <td>
                                    <strong><span class="js-installment-amount">{{ installment.quantity }}</span></strong>
                                    <span>{% if installment.quantity > 1 %}{{ 'installments.installment' | t }}{% else %}{{ 'payments.installment' | t }}{% endif %}</span>
                                    <span>{{ 'installments.of' | t }}</span>
                                    <strong><span class="js-installment-price">{{ installment.amountInCents | money }}</span></strong>
                                    {% if installment.withoutInterest %}
                                        {{ 'installments.no_interest' | t }}
                                    {% endif %}
                                </td>

                                {# Description #}
                                <td>
                                    <small>{{ installment.description }}</small>
                                </td>

                                {# Total Price #}
                                <td class="payments-table-total">
                                    <strong><span class="payments-total-label">{{ 'payments.total' | t }} </span></strong>
                                    <span class="js-installment-total-price">{{ installment.totalAmountInCents | money }}</span>
                                </td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>

                {# Payment Method Logos #}
                {% if installmentGroup.logos is not empty %}
                    <div class="payments-logos-group">
                        {% for logo in installmentGroup.logos %}
                            <span>
                                {% include 'snippets/image.tpl' with {
                                    image_src: logo | payment_new_logo,
                                    image_alt: paymentMethod.name,
                                    image_classes: 'card-img card-img-medium',
                                    image_lazy_js: true,
                                    image_thumbs: false,
                                } %}
                            </span>
                        {% endfor %}
                    </div>
                {% endif %}
            {% endfor %}
        {% endif %}
    </div>
{% endfor %}
