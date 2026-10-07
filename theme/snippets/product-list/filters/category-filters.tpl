{#
  Category Filters
  Category list filter for product grid.
#}
{% set category_filters_title = category_filters_title ?? true %}
{% set parent_category_link = parent_category_link ?? true %}

{% if filter_categories is not empty %}
    {% if parent_category_link and parent_category and parent_category.id!=0 %}
        <a href="{{ parent_category.url }}" title="{{ parent_category.name }}" class="category-back">
            <svg class="category-back-icon icon-inline"><use xlink:href="#chevron"/></svg>
            {{ parent_category.name }}
        </a>
    {% endif %}

    {% if filter_categories %}
        
        <div class="{% if accordion %}js-accordion-private-container filter-accordion{% endif %} filters-categories-container">
            {% if accordion %}
                <a href="#" class="js-accordion-private-toggle accordion-toggle">
                    <div class="accordion-toggle-label">
                        {{ 'filters.categories_title' | t }}
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
            {% elseif category_filters_title %}
                <div class="filters-title">{{ 'filters.categories_title' | t }}</div>
            {% endif %}
            <ul class="{% if accordion %}js-accordion-private-content filters-options-accordion{% else %}filters-options bottom-line{% endif %} list-unstyled" {% if accordion %}style="display: none;"{% endif %}> 
                {% for category in filter_categories %}
                    <li class="category-item" data-item="{{ loop.index }}"><a href="{{ category.url }}" title="{{ category.name }}" class="font-small">{{ category.name }}</a></li>

                    {% if loop.index == 8 and filter_categories | length > 8 %}
                        <div class="js-accordion-private-container">
                            <div class="js-accordion-private-content" style="display: none;">
                    {% endif %}
                    {% if loop.last and filter_categories | length > 8 %}
                            </div>
                            <a href="#" class="js-accordion-private-toggle accordion-show-more">
                                <span class="js-accordion-private-toggle-inactive">{{ 'general.view_more' | t }}</span>
                                <span class="js-accordion-private-toggle-active" style="display: none;">{{ 'general.view_less' | t }}</span>
                            </a>
                        </div>
                    {% endif %}
                {% endfor %}
            </ul>
        </div>
    {% endif %}
{% endif %}
