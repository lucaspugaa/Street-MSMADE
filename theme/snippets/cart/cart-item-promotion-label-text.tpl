{#
  Cart Item Promotion Label Text
  Promotion label content for cart items: progressive discount or NxM offer text.
#}
{%- if item.product.hasVisiblePromotionLabelInCart %}
    {% if item.product.promotional_offer.isProgressiveDiscount %}
        {% if item.product.promotional_offer.parameters | length > 1 %}
            {{ 'promotions.progressive_discount_primary' | t | replace('{1}', item.product.promotional_offer.selected_threshold.discount_decimal_percentage * 100)
            ~ ' '
            ~ 'promotions.progressive_discount_secondary' | t
            }}
        {% else %}
            {{ item.product.promotional_offer.selected_threshold.discount_decimal_percentage * 100
            ~ '% OFF '
            ~ 'promotions.quantity' | t | replace('{1}', item.product.promotional_offer.selected_threshold.quantity)
            }}
        {% endif %}
    {% elseif item.product.promotional_offer.isBuyXPayY %}
        {{ 'promotions.nxm_long' | t | replace('{1}', item.product.promotional_offer.buyAmount) | replace('{2}', item.product.promotional_offer.payAmount) }}
    {% elseif item.product.promotional_offer.isPercentageOff and not hide_percentage_off_label %}
        {{ 'promotions.percentage_off' | t | replace('{1}', item.product.promotional_offer.getPercentageOffValue) }}
    {% endif %}
{%- endif %}
