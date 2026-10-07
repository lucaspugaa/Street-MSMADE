{#
  Product Item Quick Shop
  Quick shop button: modal trigger for products with variants, direct add-to-cart for simple products.
#}
{% if quick_shop and product.available and product.display_price %}

    {% set product_url_with_selected_variant = has_filters ? ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url %}
    {% set quick_shop_trigger_class = (not product.isSubscribable() ? 'js-modal-open-private js-quickshop-modal-open ' ) ~ 'btn btn-primary btn-small' ~ (slide_item ? ' js-quickshop-slide') %}

	<div class="js-item-submit-container product-item-quick-shop-container">

        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
        {% set texts = {'cart': 'general.buy', 'contact': 'general.contact_price', 'nostock': 'general.no_stock', 'catalog': 'product_item.catalog'} %}

        {% if product.isSubscribable() %}

            {% set is_subscription_only = product.isSubscriptionOnly() %}

            {% set button_text = is_subscription_only ? 'product_item.subscribe' : texts[state] %}
            {% set button_title = (is_subscription_only ? 'product_item.subscribe' | t : 'product_item.quick_shop' | t) ~ ' ' ~ product.name %}
            <a href="{{ product_url_with_selected_variant }}" class="js-product-item-subscription-quickshop-link product-item-quick-shop-modal-trigger {{ quick_shop_trigger_class }}" title="{{ button_title }}" aria-label="{{ button_title }}">
                {{ button_text | t }}
            </a>
            
        {% else %}
            {% if product.variations %}

                <span class="product-item-quick-shop-modal-trigger {{ quick_shop_trigger_class }}" title="{{ 'product_item.quick_shop' | t }} {{ product.name }}" aria-label="{{ 'product_item.quick_shop' | t }} {{ product.name }}" {{ modal_trigger_data }} data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">
                    <span class="js-open-quickshop-wording">{{ texts[state] | t }}</span>
                </span>
            {% else %}
                <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                    <input type="hidden" name="add_to_cart" value="{{product.id}}" />

                    <div class="js-item-submit-container item-submit-container position-relative">
                        <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-small {{ state }}" value="{{ texts[state] | t }}" alt="{{ texts[state] | t }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                    </div>

                    {% include 'snippets/placeholders/button-placeholder.tpl' with {direct_add: true, custom_class: 'text-left'} %}

                </form>
            {% endif %}
        {% endif %}
        
    </div>
{% endif %}
