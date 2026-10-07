{# Product quantity #}

{# Use passed parameter with fallback to global settings #}
{% set show_stock = product_stock ?? settings.product_stock %}

{% set label_text = product.isSubscribable() ? 'general.quantity' | t %}

<div class="form-quantity-container">
    {% embed "snippets/forms/form-input.tpl" with{
    type_number: true, input_value: '1',
    input_name: 'quantity' ~ item.id, 
    input_custom_class: 'js-quantity-input', 
    input_label_text: label_text,
    input_append_content: true, 
    input_group_custom_class: 'js-quantity product-quantity-input-group', 
    form_control_container_custom_class: 'product-quantity-control',
    form_data_component: 'product.adding-amount',
    form_control_quantity: true,
    input_min: '1',
    data_component: 'adding-amount.value',
    input_aria_label: 'general.change_quantity' | t } %}
        {% block input_prepend_content %}
        <div class="form-quantity grid grid-3-auto grid-no-gap align-items-center" data-component="product.quantity">
            <span class="js-quantity-down form-quantity-icon btn icon-45px" data-component="product.quantity.minus">
                <svg class="icon-inline"><use xlink:href="#minus"/></svg>
            </span>
        {% endblock input_prepend_content %}
        {% block input_append_content %}
            <span class="js-quantity-up form-quantity-icon btn icon-45px" data-component="product.quantity.plus">
                <svg class="icon-inline"><use xlink:href="#plus"/></svg>
            </span>
        </div>
        {% endblock input_append_content %}
    {% endembed %}
    {% if show_stock %}
        <div class="product-quantity-stock">
            <span class="js-product-stock product-stock-number">{{ product.selected_or_first_available_variant.stock }}</span>
            <span class="js-stock-available-label product-stock-label" data-plural="{{ 'product.stock_available' | t }}" data-singular="{{ 'product.stock_available_singular' | t }}">{{ product.selected_or_first_available_variant.stock == 1 ? ('product.stock_available_singular' | t) : ('product.stock_available' | t) }}</span>
        </div>
    {% endif %}
</div>
