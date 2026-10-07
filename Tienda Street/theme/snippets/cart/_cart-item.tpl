{#
  Cart Item (AJAX)
  Single cart line item with image, quantity, price and remove; used in cart panel and cart page.
#}
{% set item_type_classes = item.product.is_non_shippable ? 'js-cart-item-non-shippable' : 'js-cart-item-shippable' %}
{% set item_page_classes = cart_page ? 'cart-page-item' %}
{% set compare_at_price = item.compare_at_price %}
{% set discount_percentage = item.discount_percentage %}
{% set is_gift = item.is_gift %}

{{ component('nubesdk-slot', { type: "before_line_item", pick: item.id }) }}

<div class="js-cart-item {{ item_type_classes }} cart-item {{ item_page_classes }}" data-item-id="{{ item.id }}" data-gift="{{ is_gift ? 'true' : 'false' }}" {% if not cart_page %}data-cart-ajax{% endif %} data-confirm-remove="{{ 'cart.remove_confirm' | t }}" data-store="cart-item-{{ item.product.id }}" data-component="cart.line-item">

    {# Cart item image #}

    <div class="cart-item-image-container">
        <a href="{{ item.url }}">
            {% include 'snippets/image.tpl' with {
                image_src: item.featured_image,
                image_classes: 'img-fluid cart-item-image fade-in',
                image_alt: item.short_name,
                product_image: not (item.is_placeholder ?? false),
                image_lazy_js: true,
            } %}
        </a>
    </div>
    <div class="cart-item-info-container">
        <div class="cart-item-product-info">
            {# Cart item name #}

            <div class="cart-item-name-container" data-component="line-item.name">
                <a href="{{ item.url }}" data-component="name.short-name" class="cart-item-name" data-component="line-item.name">
                    {{ item.short_name }}
                </a>
                <span class="cart-item-variant" data-component="name.short-variant-name">{{ item.short_variant_name }}</span>

                {# Cart kit components #}

                {% if item.is_kit and item.kit_components is not empty %}
                    <button type="button" class="js-modal-open-private btn btn-link cart-item-kit-link" data-target="#cart-kit-modal-{{ item.id }}" data-modal-url="#cart-kit-modal-{{ item.id }}" data-component="line-item.kit-breakdown-link">
                        {{ 'cart.view_kit_content' | t }}
                    </button>

                    {% embed 'snippets/modals/modal.tpl' with {
                        modal_id: 'cart-kit-modal-' ~ item.id,
                        position: {
                            appear_from: 'bottom',
                        },
                        layout: {
                            width_desktop: 'small',
                        },
                        title: item.short_name,
                        modal_classes: {
                            modal: 'modal-body-scrollable-auto',
                            close_icon: 'icon-inline',
                        }
                    } %}
                        {% block modal_body %}
                            {% include 'snippets/product/kit-products.tpl' with {
                                location: 'cart',
                                kit_components: item.kit_components,
                            } %}
                        {% endblock %}
                    {% endembed %}
                {% endif %}

                {% include 'snippets/cart/cart-labels.tpl' with {
                        group: true,
                        shipping_icon: true,
                        hide_percentage_off_label: true,
                    }
                %}
            </div>

            {# Cart item delete #}

            {% if not is_gift %}
                <div class="cart-item-delete {% if cart_page %}d-md-none{% endif %}">
                    <button type="button" class="js-cart-item-remove btn btn-link cart-item-delete-button" data-component="line-item.remove">
                        {{ 'general.remove' | t }}
                    </button>
                </div>
            {% endif %}
        </div>
        <div class="cart-item-totals-container">
        
            {# Cart item quantity #}

            <div class="cart-item-quantity" data-component="line-item.subtotal">
                {% embed "snippets/forms/form-input.tpl" with{
                type_number: true,
                input_value: item.quantity,
                input_name: 'quantity[' ~ item.id ~ ']',
                input_data_attr: 'item-id',
                input_data_val: item.id,
                input_custom_class: 'js-cart-quantity-input cart-quantity-input p-0',
                input_label: false,
                input_append_content: true,
                input_group_custom_class: 'js-quantity form-quantity small',
                form_data_component: 'quantity.value',
                form_control_quantity: true,
                input_disabled: is_gift,
                input_aria_label: 'general.change_quantity' | t } %}
                    {% block input_prepend_content %}
                        <div class="grid grid-3-auto grid-no-gap align-items-center">
                            <span class="js-cart-quantity-minus js-cart-quantity-btn btn cart-quantity-btn" data-component="quantity.minus">
                                <svg class="icon-inline"><use xlink:href="#minus"/></svg>
                            </span>
                    {% endblock input_prepend_content %}
                    {% block input_append_content %}
                            <span class="js-cart-input-spinner cart-item-spinner" style="display: none;">
                                <svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
                            </span>
                            <span class="js-cart-quantity-plus js-cart-quantity-btn btn cart-quantity-btn" data-component="quantity.plus">
                                <svg class="icon-inline"><use xlink:href="#plus"/></svg>
                            </span>
                        </div>
                    {% endblock input_append_content %}
                {% endembed %}
            </div>

            {% set cart_page_price_class = 'cart-item-subtotal' %}

            {% if cart_page %}
                {# Cart item unit price #}
                <div class="cart-item-unit-price d-none d-md-block">
                    {% if is_gift %}
                        <div class="cart-compare-price-container">
                            <span class="price-compare">{{ item.compare_at_price | money }}</span>
                        </div>
                        <div class="cart-item-subtotal">{{ 'general.free' | t }}</div>
                    {% else %}
                        <div class="js-cart-item-unit-price-compare-price-container cart-compare-price-container" data-line-item-id="{{ item.id }}"{% if not compare_at_price %} style="display: none"{% endif %}>
                            <span class="cart-item-discount-badge">-{{ discount_percentage }}%</span>
                            <span class="js-cart-item-unit-price-compare-price price-compare" data-line-item-id="{{ item.id }}" data-component="compare_price.value" data-component-value='{{ compare_at_price | money }}'>{{ compare_at_price | money }}</span>
                        </div>
                        <div class="js-cart-item-unit-price {{ cart_page_price_class }}" data-line-item-id="{{ item.id }}">{{ item.unit_price | money }}</div>
                    {% endif %}
                </div>
            {% endif %}

            {# Cart item subtotal #}

            <div class="cart-item-subtotal">
                {% if is_gift %}
                    <div class="cart-compare-price-container">
                        <span class="price-compare">{{ item.compare_at_price_subtotal | money }}</span>
                    </div>
                    <div>{{ 'general.free' | t }}</div>
                {% else %}
                    <div class="js-cart-item-subtotal-compare-price-container cart-compare-price-container" data-line-item-id="{{ item.id }}"{% if not item.compare_at_price_subtotal %} style="display: none"{% endif %}>
                        <span class="cart-item-discount-badge">-{{ discount_percentage }}%</span>
                        <span class="js-cart-item-subtotal-compare-price price-compare" data-line-item-id="{{ item.id }}" data-component="subtotal_compare_price.value" data-component-value='{{ item.compare_at_price_subtotal | money }}'>{{ item.compare_at_price_subtotal | money }}</span>
                    </div>
                    <div class="js-cart-item-subtotal" data-line-item-id="{{ item.id }}" data-component="subtotal.value" data-component-value='{{ item.subtotal | money }}'>{{ item.subtotal | money }}</div>
                {% endif %}
            </div>
        </div>

        {% if cart_page and not is_gift %}

            {# Cart page item delete #}

            <div class="cart-item-delete d-none d-md-block">
                <button type="button" class="js-cart-item-remove btn btn-link" data-component="line-item.remove">
                    {{ 'general.remove' | t }}
                </button>
            </div>
        {% endif %}
    </div>
</div>
