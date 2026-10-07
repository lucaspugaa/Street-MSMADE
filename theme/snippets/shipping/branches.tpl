{#
  Branches
  Store branches/pickup locations accordion for product and cart.
#}
<div class="{% if product_detail %}js-product-branches-container{% endif %} js-accordion-private-container {% if store.branches|length > 1 %}js-toggle-branches{% endif %}" data-store="branches">
    <div class="branches-header">
        <div class="form-label">
            {% if store.branches|length > 1 %}
                {{ 'shipping.our_stores' | t }}
            {% else %}
                {{ 'shipping.our_store' | t }}
            {% endif %}
        </div>
        {% if store.branches|length > 1 %}
            <button class="js-accordion-private-toggle btn btn-link font-small">
                <span class="js-accordion-private-toggle-active">
                    {{ 'shipping.view_options' | t }}
                    <svg class="branches-toggle-icon icon-inline"><use xlink:href="#chevron-down"/></svg>
                </span>
                <span class="js-accordion-private-toggle-inactive" style="display: none;">
                    {{ 'shipping.hide_options' | t }}
                    <svg class="branches-toggle-icon icon-inline"><use xlink:href="#chevron-down"/></svg>
                </span>
            </button>
        {% endif %}
    </div>

    {# Store branches #}

    <div class="js-accordion-private-content" {% if store.branches|length > 1 %}style="display: none;"{% endif %}>
        {% if not product_detail %}
            <div class="radio-buttons-group">
        {% endif %}
                <ul class="list-unstyled radio-button-container">

                    {% for branch in store.branches %}
                        <li class="{% if product_detail %}list-item-small list-item{% else %}radio-button-item{% endif %} branches-item" data-store="branch-item-{{ branch.code }}">

                            {# If cart use radiobutton #}

                            {% if not product_detail %}
                                <label class="js-shipping-radio js-branch-radio radio-button box d-block {% if cart.shipping_data.code == branch.code %}selected{% endif %}" data-loop="branch-radio-{{loop.index}}">
                            
                                    <input 
                                    class="js-branch-method {% if cart.shipping_data.code == branch.code %} js-selected-shipping-method {% endif %} shipping-method" 
                                    data-price="0" 
                                    {% if cart.shipping_data.code == branch.code %}checked{% endif %} type="radio" 
                                    value="{{branch.code}}" 
                                    data-name="{{ branch.name }} - {{ branch.extra }}"
                                    data-code="{{branch.code}}" 
                                    data-cost="{{ 'shipping.free' | t }}"
                                    name="option" 
                                    style="display:none">
                                    <div class="radio-button-content">
                                       <div class="radio-button-icons-container">
                                            <span class="radio-button-icons">
                                                <span class="radio-button-icon unchecked"></span>
                                                <span class="radio-button-icon checked"></span>
                                            </span>
                                        </div>
                            {% endif %}
                                        <div class="{% if product_detail %}list-item-content{% else %}radio-button-label{% endif %}">
                                            <div class="d-grid grid-auto-1"> 
                                                <div class="branches-item-name">
                                                    {{ branch.name }} - {{ branch.extra }}
                                                </div>
                                                <div class="branches-item-price">
                                                    {{ 'shipping.free' | t }}
                                                </div>
                                            </div>
                                        </div>
                            {% if not product_detail %}
                                    </div>
                                </label>
                            {% endif %}
                        </li>
                    {% endfor %}
                </ul>
        {% if not product_detail %}
            </div>
        {% endif %}
    </div>
</div>
