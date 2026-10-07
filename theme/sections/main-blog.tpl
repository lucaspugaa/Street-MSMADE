{#
  Blog Section
  Blog listing page with post grid and pagination.
#}
{# Layout settings #}
{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<section
  class="blog-page"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    {% if blog.posts is defined and (blog.posts | length) > 0 %}
      <div class="grid grid-spaced grid-md-3">
        {% for post in blog.posts %}
          {% include 'snippets/blog/blog-post-item.tpl' %}
        {% endfor %}
      </div>
    {% else %}
      <div class="blog-empty">
        <p class="text-muted">{{ 'blog.no_posts' | t }}</p>
      </div>
    {% endif %}
    
    {% include 'snippets/product-list/pagination.tpl' with {'pages': blog.pages} %}
  {% if page_width %}
    </div>
  {% endif %}
</section>


{% schema %}
{
  "name": "t:names.blog_posts",
  "class": "section section-main-blog",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.blog_posts"}],
  "settings": [
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
      "default": 0,
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
    "page_templates": ["blog"]
  }
}
{% endschema %}
