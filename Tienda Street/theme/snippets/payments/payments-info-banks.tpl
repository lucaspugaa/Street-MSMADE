{# Payments Info Banks
 Payment info with bank-specific installments (AR only).
 #}

{% set gateways = installmentsv2['methods'][method] ?? [] %}
{% set gateways = gateways|merge({'id': method}) %}

{# Gateways with banks #}

{# Credit cards #}
{% if gateways.cc is not null %}
  <div class="payments-section-title">{{ 'payments.credit_cards' | t }}</div>
  <div class="payments-card card">
    {# Installments without interest modules by groups, E.g: 3, 6, 9, 12 #}

    {% if gateways.cc is null or gateways.cc is empty is not null %}
      {% for installment, banks in gateways.cc.no_interest %}
        {# Banks with installments without interest flags #}

        <div class="payments-logos">
          {% for bank in banks %}
            {% include 'snippets/image.tpl' with {
              image_src: bank | bank_code_by_name | payment_new_logo,
              image_alt: bank,
              image_classes: 'card-img card-img-medium',
              image_lazy_js: true,
              image_thumbs: false,
            } %}
          {% endfor %}
        </div>

        {# Installment amount, cost, CFT, 1 payment info and total cost #}

        <div class="payments-installment-amount">
          {{ installment }}
          {{ 'installments.installment' | t }}
          <span>{{ 'installments.no_interest' | t }}</span>
          {{ 'installments.of' | t }}
          <strong class="js-modal-installment-price" data-installment="{{installment}}"> {{ (product.price / installment) | money }}</strong>
        </div>
        <div class="payments-legal-info">
          <span>
            {{ 'payments.cft' | t }} 0,00%
          </span>
          <span>
            {{ 'payments.total' | t }}: <span class="js-installments-one-payment">{{ product.price | money }}</span>
          </span>
          <span>
            {{ 'payments.one_payment' | t }}: <span class="js-installments-one-payment">{{ product.price | money }}</span>
          </span>
        </div>

        <div class="divider"></div>
      {% endfor %}
    {% endif %}

    {# Installments with interest in one module #}

    {% if gateways.cc.interest is not null %}
      {# Banks with installments with interest flags #}

      <div class="payments-logos">
        {% for bank in gateways.cc.interest %}
          {% include 'snippets/image.tpl' with {
            image_src: bank | bank_code_by_name | payment_new_logo,
            image_alt: bank,
            image_classes: 'card-img card-img-medium',
            image_lazy_js: true,
            image_thumbs: false,
          } %}
        {% endfor %}
      </div>

      {# Installment amount #}

      <div class="payments-interest-info">
        {{ gateways.max_with_interests }} {{ 'payments.installments_with_other_cards' | t }}
      </div>
      <div class="payments-method-price">
        {{ 'payments.or_one_payment' | t }}:
        <strong class="js-installments-one-payment">{{ product.price | money }}</strong>
      </div>

      <div class="divider"></div>
    {% endif %}
  </div>
{% endif %}

{# Cash methods #}

{% if gateways.debit is not null or gateways.cash is not null or gateways.transfer is not null %}
  <div class="payments-section-title">{{ 'payments.debit_card_and_cash' | t }}</div>
  <div class="payments-card card">

    {# Debit card #}

    {% if gateways.debit is not null %}

      {# Debit flags #}

      <div class="payments-logos">
        {% for logo in gateways.debit %}
          {% include 'snippets/image.tpl' with {
            image_src: logo | payment_new_logo,
            image_alt: logo,
            image_classes: 'card-img card-img-medium',
            image_lazy_js: true,
            image_thumbs: false,
          } %}
        {% endfor %}
      </div>

      {# Debit price #}

      <div class="payments-method-title">{{ 'payments.debit' | t }}</div>
      <div class="payments-method-price">
        <span>{{ 'payments.price' | t }}: </span><strong class="js-installments-one-payment"> {{ product.price | money }}</strong>
      </div>

      <div class="divider"></div>

    {% endif %}

    {# Cash #}

    {% if gateways.cash is not null %}

      {# Cash flags #}

      <div class="payments-logos">
        {% for logo in gateways.cash %}
          {% include 'snippets/image.tpl' with {
            image_src: logo | payment_new_logo,
            image_alt: logo,
            image_classes: 'card-img card-img-medium',
            image_lazy_js: true,
            image_thumbs: false,
          } %}
        {% endfor %}
      </div>

      {# Cash price #}

      <div class="payments-method-title">{{ 'payments.cash' | t }}</div>
      <div class="payments-method-price">
        <span>{{ 'payments.price' | t }}: </span><strong class="js-installments-one-payment"> {{ product.price | money }}</strong>
      </div>

      <div class="divider"></div>

    {% endif %}

    {# Wire transfer #}

    {% if gateways.transfer is not null %}

      {# Transfer logos #}

      <div class="payments-logos">
        {% for logo in gateways.transfer %}
          {% include 'snippets/image.tpl' with {
            image_src: logo | payment_new_logo,
            image_alt: logo,
            image_classes: 'card-img card-img-medium',
            image_lazy_js: true,
            image_thumbs: false,
          } %}
        {% endfor %}
      </div>

      {# Transfer price #}

      <div class="payments-method-title">{{ 'payments.transfer' | t }}</div>
      <div class="payments-method-price">
        <span>{{ 'payments.price' | t }}: </span><span class="js-installments-one-payment"> {{ product.price | money }}</span>
      </div>

      <div class="divider"></div>

    {% endif %}
  </div>
{% endif %}

{# Supported Payment Methods #}
{% include 'snippets/payments/payments-info-methods.tpl' with {paymentProvider: gateways, product: product} %}
