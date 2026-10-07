{# Payments Info
 Payment method info (cards, cash) and installments.
 #}

{% set installments_data = installmentsv2['methods'][method] ?? [] %}
{% set installments_data = installments_data|merge({'id': method}) %}

{# Gateways without banks: cards only #}

{% if installments_data['cards'] %}

    {# Credit cards #}

    <div class="payments-section-title">{{ 'payments.credit_cards' | t }}</div>
    <div id="installment-credit-card-option-{{ method }}" class="payments-card card">

        {# Credit cards flags #}

        <div class="payments-logos">
            {% for logo in installments_data['cards'] %}
                {% include 'snippets/image.tpl' with {
                    image_src: logo | payment_new_logo,
                    image_alt: logo,
                    image_classes: 'card-img card-img-medium',
                    image_lazy_js: true,
                    image_thumbs: false,
                } %}
            {% endfor %}
        </div>

        {# Credit cards max installments only for AR stores #}

        {% if store.country == 'AR' %}

            {% if installments_data['max_without_interests'] > 1 %}
                <div class="payments-installment-highlight">
                    {{ installments_data['max_without_interests'] }}
                    {{ 'installments.installment' | t }}
                    <span>{{ 'installments.no_interest' | t }}</span>
                    {{ 'installments.of' | t }}
                    <strong class="js-modal-installment-price" data-installment="{{ installments_data['max_without_interests'] }}"> {{ (product.price / installments_data['max_without_interests']) | money }}</strong>
                </div>
                <div class="payments-legal-info">
                    <span>
                        {{ 'payments.cft' | t }} 0,00%
                    </span>
                    <span>
                        {{ 'payments.total' | t }}: <span class="js-installments-one-payment">{{ product.price | money }}</span>
                    </span>
                    <span>{{ 'payments.one_payment' | t }}: <span class="js-installments-one-payment">{{ product.price | money }}</span></span>
                </div>
            {% elseif installments_data['max_with_interests'] > 1 %}
                <div class="payments-installment-highlight">
                    {{ 'payments.up_to' | t }}
                    {{ installments_data['max_with_interests'] }}
                    {{ 'installments.installment' | t }}
                </div>
                <div class="payments-legal-info">
                    {{ 'payments.or_one_payment' | t }}: <span class="js-installments-one-payment">{{ product.price | money }}</span>
                </div>
            {% else %}
                <div class="payments-installment-highlight">
                    <span>{{ 'payments.one_payment' | t }}: </span><strong class="js-installments-one-payment">{{ product.price | money }}</strong>
                </div>
            {% endif %}

        {% endif %}

        {% if store.country != 'AR' %}

            {# Installments list for non AR stores #}

            <table class="table">
                <thead>
                    <tr>
                        <th colspan="2">{{ 'payments.installments' | t }}</th>
                        <th class="payments-table-total">{{ 'payments.total' | t }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for installment, data_installment in installments %}
                        {% set rounded_installment_value = data_installment.installment_value | round(2) %}
                        {% set total_value = (data_installment.without_interests ? data_installment.total_value : installment * data_installment.installment_value) %}
                        {% set total_value_in_cents = total_value  | round(2) * 100 %}
                        <tr id="installment_{{ method }}_{{ installment }}">

                            {# Installment amount #}

                            <td>
                                <strong><span class="js-installment-amount">{{ installment }}</span></strong>
                                <span>{% if installment > 1 %}{{ 'installments.installment' | t }}{% else %}{{ 'payments.installment' | t }}{% endif %}</span>
                            </td>

                            {# Installment price #}

                            <td>
                                <span>{{ 'installments.of' | t }}</span>
                                <strong><span class="js-installment-price">{{ (rounded_installment_value * 100) | money }}</span> </strong>

                                {% if data_installment.without_interests or installments_data['max_with_interests'] == 0 %}
                                    {{ 'installments.no_interest' | t }}
                                {% endif %}
                            </td>

                            {# Total price #}

                            <td class="js-installment-total-price payments-table-total">
                                {{ total_value_in_cents | money }}
                            </td>
                        </tr>
                    {% endfor %}
                </tbody>
            </table>
        {% endif %}
    </div>
{% endif %}

{# Cash methods #}

{% if installments_data['direct'] %}

    {# Cash module title #}

    <div class="payments-section-title">
        {% if store.country == 'BR' %}
            {% if wording_method_only_cash %}
                {{ 'payments.cash' | t }}
            {% elseif wording_method_only_debit %}
                {{ 'payments.online_debit' | t }}
            {% else %}
                {{ 'payments.online_debit_and_cash' | t }}
            {% endif %}
        {% else %}
            {{ 'payments.debit_card_and_cash' | t }}
        {% endif %}
    </div>

    {# If has debit card or cash #}

    <div id="installment-cash-option-{{ method }}" class="payments-card card">

        {# Cash flags #}

        <div class="payments-logos">
            {% for logo in installments_data['direct'] %}
                {% include 'snippets/image.tpl' with {
                    image_src: logo | payment_new_logo,
                    image_alt: logo,
                    image_classes: 'card-img card-img-medium',
                    image_lazy_js: true,
                    image_thumbs: false,
                } %}
            {% endfor %}
        </div>

        {# Cash total #}

        <div class="payments-installment-highlight">
            <span>{{ 'payments.total' | t }}:</span><strong class="js-installments-one-payment">{{ product.price | money }}</strong>
        </div>

    </div>
{% endif %}

{# Supported Payment Methods #}
{% include 'snippets/payments/payments-info-methods.tpl' with {paymentProvider: installments_data, product: product} %}
