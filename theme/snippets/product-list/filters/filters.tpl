{#
  Filters
  Product grid filters container (category + property filters).
#}
{% set category_filters = category_filters ?? true %}
{% set property_filters = property_filters ?? true %}

{% if category_filters %}
    {% include 'snippets/product-list/filters/category-filters.tpl' %}
{% endif %}
{% if property_filters %}
    {% include 'snippets/product-list/filters/property-filters.tpl' %}
{% endif %}
