{# Set related products classes #}

{% set container_class = 'related-cart-notification' %}
{% set products_container_class = 'position-relative' %}
{% set title_conainer_class = 'text-center' %}
{% set title_class = 'related-cart-notification-title' %}
{% set slider_container_class = 'swiper-container' %}
{% set swiper_wrapper_class = 'swiper-wrapper ' %}
{% set slider_control_pagination_class = 'swiper-pagination swiper-pagination-bullets swiper-pagination-outside w-100 d-md-none' %}
{% set slider_controls_container_class = 'swiper-button-outside' %}
{% set slider_control_prev_class = 'swiper-button-prev ' ~ slider_controls_container_class %}
{% set slider_control_next_class = 'swiper-button-next ' ~ slider_controls_container_class %}

{# Related cart products #}

{% set related_section_id = 'related-products-notification' %}

{% set related_products = related_products_list | length > 0 %}

{% if related_products %}
    {% include 'snippets/product-list/products-section.tpl' with {
        title: 'product.add_to_purchase' | t,
        id: related_section_id,
        data_component: related_section_id,
        products_amount: related_products_list | length,
        products_array: related_products_list,
        product_template_path: 'snippets/product-list/product-item/item.tpl',
        product_template_params: {'slide_item': true, 'reduced_item': true},
        slider_controls_position: 'bottom',
        slider_pagination: true,
        section_classes: {
            section: 'js-related-products-notification',
            container: container_class,
            title_container: title_conainer_class,
            title: title_class,
            products_container: products_container_class,
            slider_container: 'js-related-products-notification-slider ' ~ slider_container_class,
            slider_wrapper: swiper_wrapper_class,
            slider_control_pagination: 'js-related-products-notification-slider-pagination ' ~ slider_control_pagination_class,
            slider_control_prev_container: 'js-related-products-notification-slider-prev ' ~ slider_control_prev_class,
            slider_control_next_container: 'js-related-products-notification-slider-next ' ~ slider_control_next_class,
        },
    } %}
{% endif %}
