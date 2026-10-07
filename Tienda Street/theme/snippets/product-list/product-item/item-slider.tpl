{#
  Product Item Slider
  Image slider for product grid items with prev/next controls and pagination dots.
#}

<div class="js-product-item-slider-container-private product-item-slider-container {{ product_item_image_classes.slider_container }}" 
    data-item-slider-id="{{ product.id }}" 
    data-initial-slides="{{ initial_images_limit }}"
    data-max-slides="{{ max_images_limit }}"
    data-images-count="{{ product.images_count }}"
    {% if product.images_count > initial_images_limit %}
        data-append-images="{{ image_data | json_encode }}"
    {% endif %}
    >
    
    <div class="product-item-slider-wrapper {{ product_item_image_classes.slider_wrapper }}">
        {% for image in product.images | slice(0, initial_images_limit) %}
            <div class="js-product-item-slider-slide-private product-item-slider-slide {{ product_item_image_classes.slider_slide }}" data-image="{{image.id}}" data-image-position="{{loop.index0}}">
                
                {% if loop.first %}
                    {% include 'snippets/image.tpl' with common_image_params | merge({
                            image_src: image,
                            image_alt: image.alt,
                            image_classes: common_image_params.image_classes ~ ' ' ~ (loop.first ? image_featured_class ~ product_item_image_classes.image_featured : ''),
                            image_priority_high: image_priority_high,
                        }) %}
                    {% if show_secondary_image %}
                        {% include 'snippets/image.tpl' with common_image_params | merge({
                                image_src: product.other_images | first,
                                image_data_expand: image_secondary_data_expand,
                                image_data_sizes: image_secondary_data_sizes,
                                image_priority_high: false,
                                image_classes: common_image_params.image_classes ~ ' js-product-item-secondary-image-private product-item-image-secondary ' ~ product_item_image_classes.image_secondary,
                            }) %}
                    {% endif %}
                    {% if placeholder %}
                        <div class="{{ product_item_image_classes.placeholder }}">
                        </div>
                    {% endif %}
                {% else %}
                    {% include 'snippets/image.tpl' with common_image_params | merge({
                            image_src: image,
                            image_alt: image.alt,
                            image_priority_high: false,
                            image_classes: common_image_params.image_classes,
                        }) %}
                {% endif %}
            </div>
        {% endfor %}
    </div>
    
    {# Slider controls #}
    
    {% if slider_controls and product.images_count > 1 %}
        {% if slider_controls_container %}
            <div class="product-item-slider-controls-container {{ product_item_image_classes.slider_controls_container }}">
        {% endif %}
                {% if slider_direction_controls_container %}
                    <div class="js-product-item-slider-direction-controls-container product-item-slider-direction-controls-container {{ product_item_image_classes.slider_direction_controls_container }}">
                {% endif %}
                        <button type="button" class="js-product-item-prev-container-private product-item-prev-container {{ product_item_image_classes.slider_control_prev_container }}" data-item-slider-id="{{ product.id }}" aria-label="{{ 'product_item.previous_image' | t }}">
                            <svg class="product-item-slider-control product-item-slider-control-prev slider-arrow slider-arrow-prev icon-inline" aria-hidden="true" focusable="false"><use xlink:href="#arrow-long"/></svg>
                        </button>
                        <button type="button" class="js-product-item-next-container-private product-item-next-container {{ product_item_image_classes.slider_control_next_container }}" data-item-slider-id="{{ product.id }}" aria-label="{{ 'product_item.next_image' | t }}">
                            <svg class="product-item-slider-control product-item-slider-control-next slider-arrow icon-inline" aria-hidden="true" focusable="false"><use xlink:href="#arrow-long"/></svg>
                        </button>
                {% if slider_direction_controls_container %}
                    </div>
                {% endif %}
                {% if slider_pagination_container %}
                    <div class="js-product-item-slider-pagination-container-private product-item-slider-pagination-container {{ product_item_image_classes.slider_control_pagination_container }}">
                {% endif %}
                        {% if slider_pagination %}
                            <div class="js-product-item-slider-pagination-private product-item-slider-pagination-private product-item-slider-pagination {{ product_item_image_classes.slider_control_pagination }}" data-item-slider-id="{{ product.id }}"></div>
                        {% endif %}
                {% if slider_pagination_container %}
                    </div>
                {% endif %}
        {% if slider_controls_container %}
            </div>
        {% endif %}
    {% endif %}
</div>
