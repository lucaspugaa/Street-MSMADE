{#
  Shipping Suboption Select
  Pickup point suboptions for shipping methods; opens modal with addresses.
#}
{% set selected_option = loop.first or cart.shipping_option == option.name %}
<div class="js-shipping-suboption shipping-suboption {{suboptions.name}}">

    {% if suboptions.options %}

        {# Read only suboptions inside popup #}

        {% set modal_id_val = (suboptions.name | sanitize) ~ '-pickup-modal-' ~ random() %}

        <button data-target="#{{ modal_id_val }}" class="js-modal-open-private btn btn-link font-small">{{ 'shipping.view_addresses' | t }}</button>

        {% embed 'snippets/modals/modal.tpl' with {
            modal_id: modal_id_val,
            data_component: modal_id_val,
            position: {
                appear_from: 'bottom',
            },
            layout: {
                width_mobile: 'small',
                width_desktop: 'small',
            },
            title: 'shipping.pickup_points' | t,
            modal_classes: {
                close_icon: 'icon-inline',
            }
        } %}
            {% block modal_body %}
                <ul class="shipping-suboption-list">
                    {% for option in suboptions.options %}
                        <li class="shipping-suboption-name">{{ option.name | lower }}</li>
                    {% endfor %}
                </ul>
                <div class="shipping-suboption-zipcode">
                    <span>{{ 'shipping.nearby_zipcode' | t }}</span> <span class="font-weight-bold">{{cart.shipping_zipcode}}</span>
                </div>
                <div class="shipping-suboption-note">
                    {% include 'snippets/icon.tpl' with { name: 'info', size: 16 } %}
                    <i>{{ 'shipping.choose_options_later' | t }}</i>
                </div>
            {% endblock %}
        {% endembed %}

    {% else %}
        <input type="hidden" name="{{suboptions.name}}"/>
        <div>{{ suboptions.no_options_message | t }}</div>
    {% endif %}
</div>
