{#
  Remove Filters
  Applied filters chips with remove-all option.
#}
{% if has_applied_filters %}

    {% set remove_filter_name = remove_filter_name ?? false %}

    <div class="mb-md-4 pb-md-2">
        <div class="filters-applied-heading">{{ 'filters.applied.label' | t }}</div>
        {% for product_filter in product_filters %}
            {% for value in product_filter.values %}

                {# List applied filters as tags #}
                
                {% if value.selected %}
                    <button class="js-remove-filter-private chip" data-filter-name="{{ product_filter.key }}" data-filter-value="{{ value.name }}" data-component="filter.pill-{{ product_filter.type }}" data-component-value="{{ product_filter.key }}">
                        {% if remove_filter_name %}
                            {{ product_filter.key }}:
                        {% endif %}
                        {{ value.pill_label }}
                        <svg class="filter-remove-icon chip-remove-icon"><use xlink:href="#times"/></svg>
                    </button>
                {% endif %}
            {% endfor %}
        {% endfor %}
        <a href="#" class="js-remove-all-filters-private filter-remove-all" data-component="filter-delete">{{ 'filters.applied.remove_all' | t }}</a> 
    </div>
{% endif %}
