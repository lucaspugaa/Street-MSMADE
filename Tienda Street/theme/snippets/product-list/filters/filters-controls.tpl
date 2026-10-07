{#
  Filters Controls
  Filter and sort buttons with options for category grid.
#}
{% if products and has_filters_available %}
  <div class="filters-controls-content">
    {% if has_applied_filters %}
      {% include 'snippets/product-list/filters/remove-filters.tpl' %}
    {% else %}
      <h2 class="filters-desktop-heading">{{ 'general.filter_by' | t }}</h2>
    {% endif %}
    <div class="filters-desktop-content">
      {% include 'snippets/product-list/filters/filters.tpl' %}
    </div>
  </div>
{% endif %}
