{#
  Hero Section
  Displays a full-width hero banner with customizable background image,
  overlay, and content blocks (text, buttons).
#}
{% set hero = section.settings %}

{# Images #}
{% set has_mobile_image = hero.use_mobile_image and hero.image_mobile %}
{% set has_responsive_images = hero.image and has_mobile_image %}
{% set show_placeholder = not hero.image %}
{% set image_alt = hero.image | media_alt | default('accessibility.hero' | t) %}
{% set image_mobile_alt = hero.image_mobile | media_alt | default('accessibility.hero' | t) %}

{# Height #}
{% set height = hero.height %}
{% set auto_height = hero.auto_height %}

{# Alignment #}
{% set horizontal_align = hero.alignment | default('center') %}
{% set vertical_align = hero.alignment_vertical | default('center') %}
{% set horizontal_align_class = horizontal_align == 'start' ? 'left' : (horizontal_align == 'end' ? 'right' : 'center') %}
{% set vertical_align_class = vertical_align %}

{% if vertical_align_class == 'center' and horizontal_align_class == 'center' %}
  {% set content_position_class = 'media-content-center' %}
{% else %}
  {% set content_position_class = 'media-content-' ~ vertical_align_class ~ '-' ~ horizontal_align_class %}
{% endif %}

{# Text color #}
{% set text_color = hero.text_color %}

{# Overlay #}
{% set show_overlay = hero.show_overlay %}
{% set overlay_color = hero.overlay_color | default('#000000') %}
{% set overlay_opacity = show_overlay ? ((hero.overlay_opacity | default(30)) / 100) : 0 %}

{# Spacing #}
{% set gap = hero.gap | default(16) %}
{% set vertical_padding = hero.vertical_padding | default(0) %}
{% set horizontal_padding = hero.horizontal_padding | default(0) %}
{% set content_animation = hero.content_animation | default('none') %}
{% set parallax = hero.parallax %}


<div class="hero section-full-width media {{ auto_height ? 'media-auto' : 'media-full-width' }} {% if parallax %}hero-parallax{% endif %}" style="{% if not auto_height %}min-height: {{ height }}vh; {% endif %}{% if show_overlay %}--media-overlay-color: {{ overlay_color }}; --media-overlay-opacity: {{ overlay_opacity }};{% endif %} {% if text_color %}color: {{ text_color }};{% endif %}">
  {% set is_priority_section = section.index <= (template in ['home', 'product'] ? 1 : 2) %}
  <div class="{% if parallax %}js-hero-parallax{% endif %} media-visual">
    {# Desktop image #}
    {% if hero.image %}
      {% set desktop_lazy = has_responsive_images or not is_priority_section %}
      {% include 'snippets/image.tpl' with {
        image_src: hero.image,
        image_alt: image_alt,
        image_classes: (has_responsive_images ? 'd-none d-md-block ') ~ (desktop_lazy ? 'fade-in'),
        image_priority_high: not has_responsive_images and is_priority_section,
        image_lazy_js: desktop_lazy,
        image_width: hero.image_width,
        image_height: hero.image_height,
        image_aspect_ratio: hero.image_width and hero.image_height,
      } %}
      {% if desktop_lazy %}
        <div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-none d-md-block' }}"></div>
      {% endif %}
    {% elseif show_placeholder %}
      {% include 'snippets/image.tpl' with {
        image_src: ('images/placeholders/hero/hero.webp') | static_url,
        image_alt: 'accessibility.hero' | t,
        image_classes: 'fade-in',
        image_lazy_js: true,
        image_thumbs: false,
        image_width: 1280,
        image_height: 700,
        image_aspect_ratio: true,
      } %}
      <div class="placeholder placeholder-fade"></div>
    {% endif %}

    {# Mobile image #}
    {% if has_mobile_image %}
      {% include 'snippets/image.tpl' with {
        image_src: hero.image_mobile,
        image_alt: image_mobile_alt,
        image_classes: (has_responsive_images ? 'd-md-none ') ~ (not is_priority_section ? 'fade-in'),
        image_priority_high: is_priority_section,
        image_lazy_js: not is_priority_section,
        image_width: hero.image_mobile_width,
        image_height: hero.image_mobile_height,
        image_aspect_ratio: hero.image_mobile_width and hero.image_mobile_height,
      } %}
      {% if not is_priority_section %}
        <div class="placeholder placeholder-fade {{ has_responsive_images ? 'd-md-none' }}"></div>
      {% endif %}
    {% endif %}

    {# Overlay #}
    {% if show_overlay %}
      <div class="media-overlay"></div>
    {% endif %}
  </div>

  {# Content #}
  <div class="media-content media-content-floating {{ content_position_class }} {% if hero.link %}media-content-linked{% endif %} {% if content_animation != 'none' %}media-content-animate media-content-animate-{{ content_animation }}{% endif %}" style="gap: {{ gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px;">
    {% for block in section.blocks %}
      {% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
    {% endfor %}
  </div>

  {# Full section link #}
  {% if hero.link %}
    <a href="{{ hero.link }}" class="media-link" aria-label="{{ 't:names.hero' | t }}"></a>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.hero",
  "add_section_order": 1,
  "class": "section section-hero",
  "blocks": [
    { "tags": ["general"] }
  ],
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
      "label": "t:settings.image_mobile",
      "visible_if": "{{ section.settings.use_mobile_image }}"
    },
    {
      "type": "setting",
      "setting_type": "url",
      "id": "link",
      "label": "t:settings.link"
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "start", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "end", "label": "t:options.right" }
      ],
      "default": "center",
      "vertical_options": [
        { "value": "top", "label": "t:options.top" },
        { "value": "center", "label": "t:options.center" },
        { "value": "bottom", "label": "t:options.bottom" }
      ],
      "vertical_default": "center"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "height",
      "label": "t:settings.height",
      "min": 0,
      "max": 100,
      "step": 5,
      "unit": "%",
      "default": 100,
      "icon": "height",
      "disabled_if": "{{ section.settings.auto_height }}"
    },
    {
      "type": "setting",
      "setting_type": "checkbox",
      "id": "auto_height",
      "label": "t:settings.auto_height",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "vertical_spacing"
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
      "icon": "horizontal_padding"
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_overlay",
      "label": "t:names.transparent_background",
      "default": false,
      "info": "t:settings.add_overlay",
      "header_toggle": true
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "overlay_color",
      "label": "t:settings.color",
      "default": "#000000",
      "visible_if": "{{ section.settings.show_overlay }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "overlay_opacity",
      "label": "t:settings.overlay_opacity",
      "min": 0,
      "max": 100,
      "step": 5,
      "unit": "%",
      "default": 30,
      "visible_if": "{{ section.settings.show_overlay }}"
    },
    {
      "type": "header",
      "content": "t:names.animation"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "content_animation",
      "label": "t:settings.content_animation",
      "options": [
        { "value": "none", "label": "t:options.none" },
        { "value": "fade", "label": "t:options.fade" },
        { "value": "slide-up", "label": "t:options.slide_up" },
        { "value": "slide-down", "label": "t:options.slide_down" }
      ],
      "default": "none"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "parallax",
      "label": "t:settings.parallax",
      "default": false
    }
  ],
  "presets": [
    {
      "name": "t:names.hero",
      "category": "t:categories.media",
      "settings": {
        "gap": 16,
        "vertical_padding": 32,
        "horizontal_padding": 32
      },
      "blocks": [
        { "type": "heading", "settings": { "title": "t:defaults.hero.heading", "size": "h1" } },
        { "type": "text", "settings": { "text": "t:defaults.hero.description" } },
        { "type": "button", "settings": { "label": "t:defaults.hero.button" } }
      ]
    }
  ]
}
{% endschema %}
