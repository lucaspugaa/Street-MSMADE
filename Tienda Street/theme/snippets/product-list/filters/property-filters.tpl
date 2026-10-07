{#
  Property Filters
  Product property filters (brand, color, etc.) with price filter child.
#}
{% if product_filters is not empty %}

    {# Filters list #}

    <div id="filters" class="filters-properties-container" data-store="filters-nav">
        {% for product_filter in product_filters %}
            {% if product_filter.type == 'price' %}
                {% include 'snippets/product-list/filters/price-filter.tpl' %}

            {% else %}
                {% if product_filter.has_products %}
                
                    <div class="js-filter-container {% if accordion %}js-accordion-private-container filter-accordion{% endif %}" data-store="filters-group" data-component="list.filter-{{ product_filter.type }}" data-component-value="{{ product_filter.key }}">
                        {% if accordion %}
                            <a href="#" class="js-accordion-private-toggle accordion-toggle" data-accordion-target="{{ product_filter.key }}">
                                <div class="accordion-toggle-label">
                                    {{product_filter.name}}
                                    {% if has_applied_filters and applied_filters_badge %}
                                        <span class="js-filters-badge filters-badge" style="display: none;"></span>
                                    {% endif %}
                                </div>
                                <div class="accordion-toggle-icon">
                                    <span class="js-accordion-private-toggle-inactive">
                                        <svg class="icon-inline"><use xlink:href="#chevron-down"/></svg>
                                    </span>
                                    <span class="js-accordion-private-toggle-active" style="display: none;">
                                        <svg class="icon-inline"><use xlink:href="#chevron-down"/></svg>
                                    </span>
                                </div>
                            </a>
                        {% else %}
                            <h6 class="filters-title">
                                {{product_filter.name}}
                            </h6>
                        {% endif %}
                        <div class="{% if accordion %}js-accordion-private-content filters-options-accordion{% else %}filters-options bottom-line{% endif %}" {% if accordion %}style="display: none;"{% endif %}> 
                            {% set index = 0 %}
                            {% for value in product_filter.values %}
                                {% if value.product_count > 0 %}
                                    {% set index = index + 1 %}

                                    <label class="js-filter-checkbox {% if not value.selected %}js-apply-filter-private{% else %}js-remove-filter-private{% endif %} checkbox-container" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}" data-component="filter.option" data-component-value="{{ value.name }}">
                                        <input type="checkbox" autocomplete='off' {% if value.selected %}checked{% endif %}/>
                                        <span class="checkbox {% if loop.last and product_filter.values_with_products < 8 %}m-0{% endif %}">
                                            <span class="checkbox-icon"></span>
                                            <span class="checkbox-text">
                                                {{ value.name }} ({{ value.product_count }})
                                            </span>
                                            {% if product_filter.type == 'color' and value.color_type == 'insta_color' %}
                                                <span class="checkbox-color" style="background-color: {{ value.color_hexa }};"></span>
                                            {% endif %}
                                        </span>
                                    </label>
                                    {% if index == 8 and product_filter.values_with_products > 8 %}
                                        <div class="js-accordion-private-container">
                                            <div class="js-accordion-private-content" style="display: none;">
                                    {% endif %}
                                    
                                {% endif %}
                                {% if loop.last and product_filter.values_with_products > 8 %}
                                            </div>
                                            <a href="#" class="js-accordion-private-toggle accordion-show-more">
                                                <span class="js-accordion-private-toggle-inactive">{{ 'general.view_more' | t }}</span>
                                                <span class="js-accordion-private-toggle-active" style="display: none;">{{ 'general.view_less' | t }}</span>
                                            </a>
                                        </div>
                                {% endif %}
                            {% endfor %}
                        </div>
                    </div>
                {% endif %}
            {% endif %}
        {% endfor %}
    </div>
    
    <div class="js-filters-private-overlay filters-overlay" style="display: none;">
        <div class="filters-updating-message">
            <span class="js-applying-filter filters-updating-text" style="display: none;">{{ 'filters.feedback.applying' | t }}</span>
            <span class="js-removing-filter filters-updating-text" style="display: none;">{{ 'filters.feedback.removing' | t }}</span>
            <span class="js-filtering-spinner filtering-spinner">
                <svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
            </span>
        </div>
    </div>
{% endif %}
