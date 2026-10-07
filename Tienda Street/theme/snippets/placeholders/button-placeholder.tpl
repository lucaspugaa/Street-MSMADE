{#
  Button Placeholder
  Add-to-cart button placeholder shown during product load.
#}
<div class="js-addtocart js-addtocart-placeholder btn {% if not direct_add %}btn-primary btn-block{% endif %} btn-transition {{ custom_class }} disabled" style="display: none;">
    <div class="d-inline-block">
        <span class="js-addtocart-text">
            {% if direct_add %}
                <div class="d-flex justify-content-center align-items-center btn btn-primary btn-small">
                    {{ 'general.buy' | t }}
                </div>
            {% else %}
                {{ 'general.add_to_cart' | t }}
            {% endif %}
        </span>
        <span class="js-addtocart-success transition-container {% if direct_add %} btn btn-primary btn-small{% endif %}">
            {{ 'general.done' | t }}
        </span>
        <div class="js-addtocart-adding js-addtocart-adding-text transition-container{% if direct_add %} btn btn-primary btn-small{% endif %}">
            {{ 'general.adding' | t }}
        </div>
    </div>
</div>
