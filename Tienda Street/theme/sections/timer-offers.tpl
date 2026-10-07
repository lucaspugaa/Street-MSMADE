{# Timer Offers Section #}

{% set data_store_value = claim_legacy_data_store('home-timer-offers') ? 'home-timer-offers' : section.id %}

{# Set store timezone based on country main cities #}
{% set store_timezone =
    store.country == 'AR' ? 'America/Argentina/Buenos_Aires' :
    store.country == 'BR' ? 'America/Sao_Paulo' :
    store.country == 'MX' ? 'America/Mexico_City' :
    store.country == 'CO' ? 'America/Bogota' :
    store.country == 'CL' ? 'America/Santiago' : 'UTC'
%}

{# Timer dates: date as YYYY-MM-DD, time as HH:MM — concat is directly parseable. #}
{% set date_pattern = '/^\\d{4}-\\d{2}-\\d{2}$/' %}
{% set time_pattern = '/^\\d{2}:\\d{2}(:\\d{2})?$/' %}

{% set start_date = section.settings.start_date %}
{% set start_time = section.settings.start_time %}
{% set end_date = section.settings.end_date %}
{% set end_time = section.settings.end_time %}

{% set inputs_valid =
	start_date matches date_pattern and start_time matches time_pattern and
	end_date matches date_pattern and end_time matches time_pattern %}

{% set start_timestamp = inputs_valid ? (start_date ~ ' ' ~ start_time) | date('U') : null %}
{% set end_timestamp = inputs_valid ? (end_date ~ ' ' ~ end_time) | date('U') : null %}
{% set valid_offer_date = start_timestamp and end_timestamp and end_timestamp > start_timestamp %}

{# In the Brand Editor preview, always render the section.
   When dates are missing, supply dummy timestamps so the JS
   shows the section and initialises the product slider.
   The countdown stays at "00 00 00" #}

{% set placeholder_countdown = is_preview and not valid_offer_date %}
{% if placeholder_countdown %}
	{% set start_timestamp = "now" | date('U') - 86400 %}
	{% set end_timestamp   = "now" | date('U') + 86400 %}
{% endif %}

{% set show_timer_offers = valid_offer_date or is_preview %}

{# Section settings #}
{% set full_width = section.settings.section_width == 'full' %}
{% set page_width = section.settings.section_width == 'page' %}
{% set gap = section.settings.gap %}
{% set vertical_padding = section.settings.vertical_padding %}
{% set horizontal_padding = full_width ? section.settings.horizontal_padding : 0 %}
{% set background_color = section.settings.background_color %}

{# Find product-list block for product data resolution #}
{% set product_list_block = null %}
{% for block in section.blocks %}
	{% if block.type == 'timer-products' %}
		{% set product_list_block = block %}
	{% endif %}
{% endfor %}

{# Products resolved by the product_list picker on the timer-products block #}
{% set products = product_list_block ? product_list_block.settings.products_source.products : null %}
{% set has_source_products = products and (products | length) > 0 %}
{% set show_products = product_list_block and (has_source_products or is_preview or not has_products) %}

{# Section styles #}
{% set section_styles %}
	{% if vertical_padding %}padding-top: {{ vertical_padding }}px; padding-bottom: {{ vertical_padding }}px;{% endif %}
	{% if horizontal_padding %}padding-left: {{ horizontal_padding }}px; padding-right: {{ horizontal_padding }}px;{% endif %}
	{% if background_color %}background-color: {{ background_color }};{% endif %}
{% endset %}

{% if show_timer_offers %}


<div
	class="js-timer-offers-section section-timer-offers {% if full_width %}section-full-width{% endif %}"
	data-store="{{ data_store_value }}"
	data-section-id="{{ section.id }}"
	{% if section_styles | trim %}style="{{ section_styles | trim }}"{% endif %}
>
	{% if page_width %}
		<div class="container">
	{% endif %}
			<div class="js-timer-offers-container flex-split-md"
				data-start-timestamp="{{ start_timestamp }}"
				data-end-timestamp="{{ end_timestamp }}"
				data-timezone="{{ store_timezone }}"
				data-products="{{ show_products ? 'true' : 'false' }}"
				data-preview="{{ is_preview ? 'true' : 'false' }}"
style="gap: {{ gap }}px;">

				{% for block in section.blocks %}
					{% if block.type == 'timer' %}
						{% include 'blocks/timer.tpl' with { block: block } %}
					{% elseif block.type == 'timer-products' and show_products %}
						{% include 'blocks/timer-products.tpl' with { block: block, products_array: products } %}
					{% endif %}
				{% endfor %}

			</div>
	{% if page_width %}
		</div>
	{% endif %}
</div>


{% endif %}

{% schema %}
{
  "name": "t:names.timer_offers",
  "icon": "CalendarIcon",
  "add_section_order": 16,
  "class": "section section-timer-offers",
  "blocks": [
    { "type": "timer", "limit": 1 },
    { "type": "timer-products", "limit": 1 }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.timer"
    },
    {
      "type": "setting",
      "setting_type": "date",
      "id": "start_date",
      "label": "t:settings.start_date"
    },
    {
      "type": "setting",
      "setting_type": "time",
      "id": "start_time",
      "label": "t:settings.start_time"
    },
    {
      "type": "setting",
      "setting_type": "date",
      "id": "end_date",
      "label": "t:settings.end_date"
    },
    {
      "type": "setting",
      "setting_type": "time",
      "id": "end_time",
      "label": "t:settings.end_time"
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
      "default": 16,
      "icon": "horizontal_spacing"
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
    }
  ],
  "presets": [
    {
      "name": "t:names.timer_offers",
      "category": "t:categories.products",
      "blocks": [
        {
          "type": "timer",
          "blocks": [
            {
              "type": "heading",
              "settings": {
                "title": "t:defaults.timer_offers.heading",
                "size": "h4"
              }
            },
            {
              "type": "text",
              "settings": {
                "text": "t:defaults.timer_offers.description"
              }
            },
            {
              "type": "timer-counter"
            },
            {
              "type": "button",
              "settings": {
                "label": "t:defaults.timer_offers.button"
              }
            }
          ]
        },
        {
          "type": "timer-products",
          "settings": {
            "title": "t:defaults.timer_offers.products_title",
            "products_source": {"kind": "collection", "id": "timer_offers"}
          }
        }
      ]
    },
    {
      "name": "t:names.timer_offers",
      "category": "t:categories.products",
      "settings": {
        "section_width": "full",
        "vertical_padding": 0,
        "horizontal_padding": 0
      },
      "blocks": [
        {
          "type": "timer",
          "settings": {
            "gap": 24
          },
          "blocks": [
            {
              "type": "group",
              "settings": {
                "direction": "column",
                "alignment": "center",
                "gap": 8
              },
              "blocks": [
                {
                  "type": "heading",
                  "settings": {
                    "title": "t:defaults.timer_offers.heading",
                    "size": "h4"
                  }
                },
                {
                  "type": "text",
                  "settings": {
                    "text": "t:defaults.timer_offers.description"
                  }
                }
              ]
            },
            {
              "type": "timer-counter",
              "settings": {
                "background_color": "#FFFFFF",
                "text_color": "#000000"
              }
            },
            {
              "type": "button",
              "settings": {
                "label": "t:defaults.timer_offers.button"
              }
            }
          ]
        }
      ]
    }
  ]
}
{% endschema %}
