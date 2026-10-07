{# Products Grid Section #}
{# Displays filters, product grid and pagination for category and search #}
{# Uses private components for filters, sorting and product items #}

{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Pagination settings #}
{% if section.settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 60 %}
{% endif %}

{% set has_real_products = products and (products | length) > 0 %}
{% set display_products = products %}
{# Show placeholders when the store has zero active products globally #}
{% if not has_products %}
	{% for i in 1..12 %}
		{% set placeholder_num = ((i - 1) % 8) + 1 %}
		{% set display_products = display_products | merge([{
			'is_placeholder': true,
			'id': 'placeholder-' ~ i,
			'name': 'product_item.example_name' | t,
			'url': '#',
			'display_price': true,
			'price': 100000,
			'has_stock': true,
			'stock': 1,
			'placeholder_image_url': ('images/placeholders/products/product-' ~ placeholder_num ~ '.webp') | static_url,
			'featured_image': { 'dimensions': { 'width': 440, 'height': 600 }, 'alt': 'product_item.example_name' | t }
		}]) %}
	{% endfor %}
{% endif %}

{# Grid ID based on template #}
{% set grid_id = template == 'search' ? 'search-grid' : 'category-grid-' ~ category.id %}

{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set full_width = section.settings.section_width == 'full' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding | default(32) %}


<div class="products-grid section-main-products-grid"
  style="{% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %} padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
  data-store="{{ grid_id }}">
  {% if page_width %}
    <div class="container">
  {% endif %}

    {# Search-specific header with results count - only shown when there ARE products #}
    {% if template == 'search' and has_real_products %}
      {% set display_query = query ? query %}
      <div class="products-grid-header">
        <h2 class="products-grid-search-heading">
          {{ 'search.showing' | t }} <strong>{{ products_count }}</strong>
          {% if (display_products | length) > 1 %}
            {{ 'search.results_for_query' | t }}
          {% else %}
            {{ 'search.result_for_query' | t }}
          {% endif %}
          <strong>"{{ display_query }}"</strong>
        </h2>
      </div>
    {% endif %}

    {# Mobile filter/sort controls + modals #}
    {% if has_filters_available %}
      {% include 'snippets/product-list/filters/filters-modals.tpl' %}
    {% endif %}

    {# Main content: Filters sidebar + Product grid #}
    <div class="grid{% if display_products and has_filters_available %} grid-md-auto-4{% endif %}">
      {# Filters sidebar (desktop) #}
      {% if has_filters_available %}
        {% include 'snippets/product-list/filters/filters-controls.tpl' %}
      {% endif %}

      {# Product grid #}
      {% set columns_mobile = section.settings.columns_mobile %}
      {% set columns = section.settings.columns %}

      {% set grid_mobile_class = 
        columns_mobile == '2' ? 'grid-2' :
        columns_mobile == '1' ? 'grid-1' : 'grid-2'
      %}

      {% set grid_desktop_class = 
        columns == '6' ? 'grid-md-6' : 
        columns == '5' ? 'grid-md-5' : 
        columns == '4' ? 'grid-md-4' : 'grid-md-4'
      %}

      <div data-store="{{ grid_id }}">
        {% if display_products %}
          {# Sort by - hidden when only placeholders are showing #}
          {% if has_real_products %}
            <div class="product-list-sort-by text-right">
              <div class="d-none d-md-inline-block">
                {% include 'snippets/product-list/filters/sort-by.tpl' %}
              </div>
            </div>
          {% endif %}

          {# Product list #}
          <div class="js-product-table grid {{ grid_mobile_class }} {{ grid_desktop_class }}">
            {# Prioritize first 2 product images for LCP. Category bumps the threshold to absorb category-hero. #}
            {% set is_priority_section = section.index <= (template == 'category' ? 3 : 2) %}
            {% for product in display_products %}
              {% include 'snippets/product-list/product-item/item.tpl' with {image_priority_high: is_priority_section and loop.index in [1, 2]} %}
            {% endfor %}
          </div>

          {# Pagination - not shown in preview mode with simulated products #}
          {% if products %}
            {% if section.settings.pagination == 'infinite' %}
              {% include "snippets/product-list/pagination.tpl" with {infinite_scroll: true} %}
            {% else %}
              {% include "snippets/product-list/pagination.tpl" with {infinite_scroll: false} %}
            {% endif %}
          {% endif %}
        {% else %}
          {# Empty state #}
          <div class="py-4" data-component="filter.message">
            {% if has_applied_filters %}
              <p class="products-grid-empty-message">{{ 'category.no_results' | t }}</p>
            {% elseif template == 'search' %}
              {# Search empty state with suggestions #}
              <p class="products-grid-search-suggestion">{{ 'search.try_different_search' | t }}</p>
              <p>{{ 'search.maybe_interested' | t }}</p>
            {% else %}
              <p class="products-grid-empty-message">{{ 'category.coming_soon' | t }}</p>
            {% endif %}
          </div>
        {% endif %}
      </div>
    </div>

    {# Featured products when search has no results #}
    {% if template == 'search' and not display_products and not has_applied_filters %}
      {% set featured_products = sections.primary.products | slice(0, 12) %}
      {% if featured_products %}
        <div class="js-products-list-slider js-products-list-slider-container search-featured-products">
          <div class="js-products-list-swiper swiper-container">
            <div class="js-swiper-products-slider swiper-wrapper swiper-products-slider flex-nowrap" 
                 data-desktop-columns="5" 
                 data-mobile-columns="2">
              {% for product in featured_products %}
                {% include 'snippets/product-list/product-item/item.tpl' with {'slide_item': true} %}
              {% endfor %}
            </div>
            <div class="js-swiper-products-list-pagination swiper-pagination swiper-pagination-bullets swiper-pagination-outside w-100"></div>
          </div>
          <button type="button" class="js-swiper-products-list-prev swiper-button-prev swiper-button-outside" aria-label="{{ 'general.previous' | t }}">
            <svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
          </button>
          <button type="button" class="js-swiper-products-list-next swiper-button-next swiper-button-outside" aria-label="{{ 'general.next' | t }}">
            <svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
          </button>
        </div>
      {% endif %}
    {% endif %}

  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.products",
  "class": "section section-main-products-grid",
  "limit": 1,
  "deletable": false,
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns",
      "label": "t:settings.columns_desktop",
      "icon": "DesktopIcon",
      "options": [
        { "value": "4", "label": "t:options.columns_4" },
        { "value": "5", "label": "t:options.columns_5" },
        { "value": "6", "label": "t:options.columns_6" }
      ],
      "default": "4"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "columns_mobile",
      "label": "t:settings.columns_mobile",
      "icon": "MobileIcon",
      "options": [
        { "value": "1", "label": "t:options.columns_1" },
        { "value": "2", "label": "t:options.columns_2" }
      ],
      "default": "2"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "pagination",
      "label": "t:settings.product_navigation",
      "options": [
        { "value": "classic", "label": "t:options.page_navigation" },
        { "value": "infinite", "label": "t:options.infinite_scroll" }
      ],
      "default": "classic"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "section_width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "page", "label": "t:options.page" },
        { "value": "full", "label": "t:options.full" }
      ],
      "default": "page"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 64,
      "icon": "vertical_padding"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_padding",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "blocks": [],
  "enabled_on": {
    "page_templates": ["category", "search"]
  },
  "presets": [
    {
      "name": "t:names.products"
    }
  ]
}
{% endschema %}
