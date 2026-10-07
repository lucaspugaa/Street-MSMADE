{#
  Featured Brands Section
  Horizontal carousel of brand logos with optional heading.
#}

{# Data store for backward compatibility #}
{% set data_store_value = claim_legacy_data_store('home-brands') ? 'home-brands' : section.id %}

{# Alignment #}
{% set text_alignment = section.settings.text_alignment | default('left') %}
{% set use_different_mobile_alignment = section.settings.use_different_mobile_alignment %}
{% set text_alignment_mobile = use_different_mobile_alignment ? (section.settings.text_alignment_mobile | default('left')) : text_alignment %}
{% set align_items_mobile = text_alignment_mobile == 'center' ? 'center' : (text_alignment_mobile == 'right' ? 'end' : 'start') %}
{% set align_items_desktop = text_alignment == 'center' ? 'center' : (text_alignment == 'right' ? 'end' : 'start') %}

{# Width #}
{% set page_width = section.settings.section_width == 'page' %}
{% set full_width = section.settings.section_width == 'full' %}

{# Colors #}
{% set background_color = section.settings.background_color %}
{% set text_color = section.settings.text_color %}

{# Spacing #}
{% set gap = section.settings.gap | default(32) %}
{% set vertical_padding = section.settings.vertical_padding | default(64) %}
{% set horizontal_padding = page_width ? 0 : (section.settings.horizontal_padding | default(32)) %}

{# Center logos only when alignment is center #}
{% set center_slides = text_alignment == 'center' %}

{# Custom styles #}
{% set custom_styles %}
  --carousel-section-edge: {{ page_width ? 'var(--gutter-container)' : horizontal_padding ~ 'px' }};
  {% if full_width %}--section-horizontal-padding: {{ horizontal_padding }}px;{% endif %}
  {% if background_color %}background-color: {{ background_color }};{% endif %}
  {% if text_color %}color: {{ text_color }};{% endif %}
{% endset %}


<div
	class="js-carousel-section carousel-section-edge featured-brands-section {% if not page_width %}section-full-width{% endif %}"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if custom_styles | trim %}style="{{ custom_styles }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
	<div class="section-title-content position-relative d-flex flex-column align-items-{{ align_items_mobile }} align-items-md-{{ align_items_desktop }} text-{{ text_alignment_mobile }} text-md-{{ text_alignment }}"
		style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px; gap: {{ gap }}px;">
		{% for block in section.blocks %}
			{% if block.type == 'brand-group' %}
				{% include 'blocks/brand-group.tpl' with { block: block, center_slides: center_slides } %}
			{% else %}
				{% include 'blocks/' ~ block.type ~ '.tpl' with { block: block } %}
			{% endif %}
		{% endfor %}
	</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% schema %}
{
  "name": "t:names.featured_brands",
  "icon": "FlagIcon",
  "add_section_order": 12,
  "class": "section section-featured-brands",
  "max_blocks": 20,
  "blocks": [
    { "tags": ["general"] }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "text_alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "center"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "use_different_mobile_alignment",
      "label": "t:settings.use_different_mobile_alignment",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "text_alignment_mobile",
      "label": "t:settings.alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "center",
      "visible_if": "{{ section.settings.use_different_mobile_alignment }}"
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
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_spacing"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 100,
      "step": 4,
      "unit": "px",
      "default": 64,
      "icon": "vertical_spacing"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 100,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_spacing",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "background_color",
      "label": "t:settings.background",
      "default": "transparent"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    }
  ],
  "presets": [
    {
      "name": "t:names.featured_brands",
      "category": "t:categories.media",
      "settings": {
        "section_width": "page",
        "gap": 32,
        "text_alignment": "center"
      },
      "blocks": [
        {
          "type": "heading",
          "settings": {
            "title": "t:defaults.featured_brands",
            "size": "h4"
          }
        },
        {
          "type": "brand-group",
          "settings": { "logo_size": 80, "gap": 40 },
          "blocks": [
            { "type": "brand-logo" },
            { "type": "brand-logo" },
            { "type": "brand-logo" },
            { "type": "brand-logo" },
            { "type": "brand-logo" },
            { "type": "brand-logo" },
            { "type": "brand-logo" }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
