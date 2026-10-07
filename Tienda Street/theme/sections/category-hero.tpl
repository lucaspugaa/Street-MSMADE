{# Category Hero Section #}
{# Hero banner image for category pages, supports general or per-category images #}

{% set page_width = section.settings.section_width == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding | default(0) %}

{% set use_category_image = section.settings.show_category_image %}
{% set has_category_images = category.images is not empty %}
{% set has_general_image = section.settings.image %}
{% set has_default_banner = "banner-products.jpg" | has_custom_image %}

{# Resolve image URL #}
{% if use_category_image and has_category_images %}
  {% set banner_image_url = category.images | first %}
{% elseif has_general_image %}
  {% set banner_image_url = section.settings.image %}
{% elseif has_default_banner %}
  {% set banner_image_url = 'banner-products.jpg' | static_url %}
{% endif %}

{% set has_image = banner_image_url is not empty %}
{% set has_mobile_image = section.settings.use_mobile_image and section.settings.image_mobile %}
{% set has_responsive_images = has_image and has_mobile_image %}
{% set image_alt = section.settings.image | media_alt | default(category.name) %}
{% set image_mobile_alt = section.settings.image_mobile | media_alt | default(category.name) %}

{% set is_priority = section.index <= 2 %}

{% if has_image %}


  <div class="category-hero"
    style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;">
    {% if page_width %}
      <div class="container">
    {% endif %}

      <div class="category-banner position-relative" data-store="category-banner">
        {% set desktop_lazy = has_responsive_images or not is_priority %}
        {% include 'snippets/image.tpl' with {
          image_src: banner_image_url,
          category_image: use_category_image and has_category_images,
          image_alt: image_alt,
          image_classes: 'img-fluid w-100' ~ (has_responsive_images ? ' d-none d-md-block') ~ (desktop_lazy ? ' fade-in'),
          image_priority_high: not has_responsive_images and is_priority,
          image_lazy_js: desktop_lazy,
          image_thumbs: (use_category_image and has_category_images) or has_general_image ? null : false,
        } %}
        {% if desktop_lazy %}
          <div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-none d-md-block' }}"></div>
        {% endif %}

        {% if has_mobile_image %}
          {% include 'snippets/image.tpl' with {
            image_src: section.settings.image_mobile,
            image_alt: image_mobile_alt,
            image_classes: 'img-fluid w-100 d-md-none' ~ (not is_priority ? ' fade-in'),
            image_priority_high: is_priority,
            image_lazy_js: not is_priority,
          } %}
          {% if not is_priority %}
            <div class="placeholder placeholder-fade d-md-none"></div>
          {% endif %}
        {% endif %}
      </div>

    {% if page_width %}
      </div>
    {% endif %}
  </div>


{% endif %}

{% schema %}
{
  "name": "t:names.category_hero",
  "class": "section section-category-hero m-0",
  "limit": 1,
  "deletable": false,
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:settings.image"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_mobile_image",
      "label": "t:settings.use_mobile_image",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image_mobile",
      "label": "t:settings.image",
      "visible_if": "{{ section.settings.use_mobile_image }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_category_image",
      "label": "t:settings.show_category_image",
      "header_toggle": true,
      "default": true
    },
    {
      "type": "paragraph",
      "content": "t:info.category_image_description",
      "visible_if": "{{ section.settings.show_category_image }}"
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
      "default": "full"
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
      "default": 0,
      "icon": "horizontal_padding",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "blocks": [],
  "enabled_on": {
    "page_templates": ["category"]
  },
  "presets": [
    {
      "name": "t:names.category_hero"
    }
  ]
}
{% endschema %}
