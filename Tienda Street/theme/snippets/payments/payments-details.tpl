{# Payments Details
 Payment methods tabs with installments and discounts.
 #}

{% set gateways = installments_info | length %}
{% set store_set_for_new_installments_view = store.is_set_for_new_installments_view %}
{# Get the array that contains the display settings for each payment method #}
{% set payment_methods_config = product.payment_methods_config %}
{% set empty_placeholder_url = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==' %}

<div class="js-tab-container">
    <ul class="js-payments-tab-group tab-group">
        {% for method, installments in installments_info %}
            {% set method_clean = method | sanitize %}
            {% set maxDiscount = payment_methods_config[method].max_discount %}
            {% set discountStyle = ((not payment_methods_config[method].should_show_discount and discounts_conditional_visibility) or maxDiscount == 0) ? 'display: none'%}
            <li id="method_{{ method_clean }}" class="js-refresh-installment-data js-installments-gw-tab js-tab tab {% if loop.first %} active {% endif %}" data-code="{{ method }}">
                <a href="#installment_{{ method_clean }}" class="js-tab-link tab-link">
                    {{ payment_methods_config[method].name }}
                    {% set hasGeneralDiscount = payment_methods_config[method].has_general_discount %}
                    <span class="js-modal-tab-discount payments-discount-badge" style="{{discountStyle}}">
                        <strong>{% if not hasGeneralDiscount %}{{ 'payments.up_to' | t }} {% endif %}{{ maxDiscount }}% {{ 'payments.off_label' | t }}</strong>
                    </span>
                </a>
            </li>
        {% endfor %}
    </ul>

    {# Gateways tab content #}

    <div class="js-tabs-content tab-content">
        {% for method, installments in installments_info %}
            {% set method_clean = method | sanitize %}
            {% set discount = product.get_gateway_discount(method) %}
            <div id="installment_{{ method_clean }}" class="js-tab-panel tab-panel {% if loop.first %} active {% endif %} js-gw-tab-pane">
                {% if store_set_for_new_installments_view %}

                    {# Payments info with readonly #}

                    {# Evaluate whether the payment method should show complete installments data #}
                    {% if payment_methods_config[method].show_full_installments %}

                        {# Payments Gateways with banks: at the moment only MP AR #}

                        {% include 'snippets/payments/payments-info-banks.tpl' %}
                    {% else %}

                        {# Payments Gateways with cards only #}

                        {% include 'snippets/payments/payments-info.tpl' %}
                    {% endif %}

                {% else %}

                    {# Installments list for ROLA stores #}

                    {% for installment, data_installment in installments %}
                        <div id="installment_{{ method }}_{{ installment }}">
                            {% set rounded_installment_value = data_installment.installment_value | round(2) %}
                            {% set total_value = (data_installment.without_interests ? data_installment.total_value : installment * data_installment.installment_value) %}
                            {% set total_value_in_cents = total_value  | round(2) * 100 %}
                            <strong class="js-installment-amount">{{ installment }}</strong> {% if store.country != 'BR' %}cuota{% if installment > 1 %}s{% endif %} de{% else %}x{% endif %} <strong class="js-installment-price">{{ (rounded_installment_value * 100) | money }}</strong>
                            {% if data_installment.without_interests and not data_installment.collector_is_third_party %} {{ 'installments.no_interest' | t }}{% endif %}
                            {% if data_installment.collector_is_third_party %} {{ 'installments.third_party_collector' | t }}{% endif %}
                        </div>
                    {% endfor %}
                {% endif %}
            </div>
        {% endfor %}
    </div>
</div>
