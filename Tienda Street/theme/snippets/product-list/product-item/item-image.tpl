{#
  Product Item Image
  Product grid image container with optional slider, secondary image and lazy loading.
#}

{% set slider_controls_container_class = slider ? 'product-item-slider-controls-container d-none d-md-block' : '' %}
{% set product_item_image_classes = {
    image: 'img-absolute img-absolute-centered fade-in',
    slider_container: 'swiper-container position-absolute h-100 w-100',
    slider_wrapper: 'swiper-wrapper',
    slider_slide: 'swiper-slide',
    slider_control_prev_container: 'swiper-button-prev ' ~ slider_controls_container_class,
    slider_control_next_container: 'swiper-button-next ' ~ slider_controls_container_class,
    slider_control_pagination_container: 'd-md-none',
    more_images_message: 'item-more-images-message',
} %}

{# Image URL #}

{% set url_with_selected_variant = has_filters ? ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

{# Image properties #}

{% set image_thumbs =
    image_thumbs ? image_thumbs :
    ['tiny', 'thumb', 'small', 'medium', 'large', 'huge', 'original', '1080p', '1440p', '4k']
%}

{% set image_width = product.featured_image.dimensions['width'] %}
{% set image_height = product.featured_image.dimensions['height'] %}
{% set image_alt = product.featured_image.alt %}
{% set image_padding_spacing = image_padding_spacing ?? true %}
{% set forced_aspect_ratio_values = { square: 100, horizontal: 75, vertical: 133.333 } %}
{% set image_padding_spacing_value = forced_aspect_ratio_values[settings.product_aspect_ratio | default('original')] | default(image_height / image_width * 100) %}
{% set product_multiple_images = product.other_images %}
{% set show_slider = slider and product_multiple_images %}
{% set show_secondary_image = secondary_image and product_multiple_images %}
{% set slider_controls = slider_controls ?? true %}
{% set slider_pagination = slider_pagination ?? true %}

{# Aspect ratio (global setting): forces a fixed crop on the product image unless 'original' #}
{% set is_forced_aspect = (settings.product_aspect_ratio | default('original')) != 'original' %}
{% set aspect_class = is_forced_aspect ? 'product-item-image-container-cropped' %}

{# Limit product images #}
{% set initial_images_limit = show_secondary_image ? 4 : 3 %}
{% set max_images_limit = 10 %}

{# Image sizes mapping #}
{% set sizes = {
    'tiny': 50,
    'thumb': 100,
    'small': 240,
    'medium': 320,
    'large': 480,
    'huge': 640,
    'original': 1024,
    'xlarge': 1400,
    '1080p': 1920,
    '1440p': 2560,
    '4k': 3840
} %}

{# Create JSON with extra slides image data #}
{% set append_slides_sizes = {} %}
{% for thumb in image_thumbs %}
    {% set append_slides_sizes = append_slides_sizes|merge({
        (thumb): sizes[thumb]
    }) %}
{% endfor %}

{% set image_data = [] %}
{% for image in product.images | slice(initial_images_limit, max_images_limit) %}
    {% set current_srcset = [] %}
    {% for thumb, size in append_slides_sizes %}
        {% set current_srcset = current_srcset|merge([image|product_image_url(thumb) ~ ' ' ~ size ~ 'w']) %}
    {% endfor %}
    {% set image_data = image_data|merge([{
        'index': loop.index + initial_images_limit,
        'thumbs': current_srcset|join(', '),
        'alt': image.alt,
        'width': image.dimensions.width,
        'height': image.dimensions.height
    }]) %}
{% endfor %}

{% set image_sizes_mobile = ((columns_mobile|default('')) == '1' and (format_mobile|default('')) == 'slider') ? '100vw' : '50vw' %}

{% set common_image_params = {
    image_width: image_width,
    image_height: image_height,
    image_alt: image_alt,
    product_image: true,
    image_lazy: true,
    image_lazy_js: true,
    image_sizes: '(min-width: 768px) 50vw, ' ~ image_sizes_mobile,
    image_thumbs: image_thumbs,
    image_data_expand: image_data_expand,
    image_data_sizes: image_data_sizes,
    image_classes: 'js-product-item-image-private product-item-image ' ~ product_item_image_classes.image,
} %}

{% set image_featured_class = show_secondary_image ? 'product-item-image-featured ' %}

<div class="js-product-item-image-container-private {% if show_secondary_image %}js-product-item-private-with-secondary-images{% endif %} product-item-image-container {{ aspect_class }} {{ product_item_image_classes.image_container }}" data-store="product-item-image-{{ product.id }}" data-images-url="{{ product.images_url }}">

    {{ component('nubesdk-slot', { type: "product_grid_item_image" }) }}

    {% if image_padding_spacing %}
        <div style="padding-bottom: {{ image_padding_spacing_value }}%;" class="{{ product_item_image_classes.image_padding_container }}">
    {% endif %}
            <a href="{{ url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="js-product-item-image-link-private {{ product_item_image_classes.image_link }}">

                {# Slider format: Including slides and controls #}

                {% if show_slider %}

                    {% include 'snippets/product-list/product-item/item-slider.tpl' %}
                    
                {% else %}

                    {# Single image format #}

                    {% include 'snippets/image.tpl' with common_image_params | merge({
                            image_src: product.is_placeholder ? product.placeholder_image_url : product.featured_image,
                            product_image: not product.is_placeholder,
                            image_thumbs: product.is_placeholder ? false : common_image_params.image_thumbs,
                            image_classes: common_image_params.image_classes ~ ' ' ~ image_featured_class ~ product_item_image_classes.image_featured,
                            image_priority_high: image_priority_high,
                        }) %}
                {% endif %}

                {# Secondary image (optional) #}

                {% if show_secondary_image and not show_slider %}
                    {% include 'snippets/image.tpl' with common_image_params | merge({
                            image_src: product.other_images | first,
                            image_data_expand: image_secondary_data_expand,
                            image_data_sizes: image_secondary_data_sizes,
                            image_priority_high: false,
                            image_classes: common_image_params.image_classes ~ ' js-product-item-secondary-image-private product-item-image-secondary ' ~ product_item_image_classes.image_secondary,
                        }) %}
                {% endif %}

                {% if placeholder and not show_slider %}
                    <div class="{{ product_item_image_classes.placeholder }}">
                    </div>
                {% endif %}
            </a>

            {% if labels %}
                {% set promotional_label_over_image = settings.promotion_labels_position == 'over' %}
                {% include 'snippets/labels.tpl' with {
                    defer_stock_label_text: true,
                    no_stock_only: not promotional_label_over_image,
                    free_shipping_only: not promotional_label_over_image,
                    without_offer: not (promotional_label_over_image and has_custom_percentage_off_promotion_label),
                    free_shipping_short_wording: true,
                    labels_classes: {
                        group: product_item_classes.labels_group,
                        no_stock: product_item_classes.label_no_stock,
                        shipping: product_item_classes.label_shipping,
                        promotion: label_accent_classes,
                        offer: label_accent_classes,
                    },
                } %}
            {% endif %}

            {# More images message #}

            {% if show_slider and (product.images_count > max_images_limit) %}
                <div class="js-product-item-more-images-message-private product-item-more-images-message {{ product_item_image_classes.more_images_message }}">
                    {% set remaining_images = product.images_count - max_images_limit %}
                    +{{ remaining_images }} {{ (remaining_images == 1 ? 'product_item.one_more_image' : 'product_item.more_images') | t }}
                </div>
            {% endif %}
    {% if image_padding_spacing %}
        </div>
    {% endif %}
</div>
