{# Brand Group - Container for brand logo carousel #}

{% set logo_blocks = [] %}
{% for child_block in block.blocks %}
	{% if child_block and child_block.type == 'brand-logo' %}
		{% set logo_blocks = logo_blocks | merge([child_block]) %}
	{% endif %}
{% endfor %}
{% set has_logos = (logo_blocks | length) > 0 %}
{% set logo_size = block.settings.logo_size | default(80) %}
{% set carousel_gap = block.settings.gap | default(16) %}
{% set visible_logo_count = logo_blocks | length %}

{% if has_logos %}
	<div class="position-relative w-100" {{ block | block_attributes }}>
		<div class="js-carousel-slider swiper overflow-hidden"
			data-columns-mode="auto"
			data-slide-gap="{{ visible_logo_count <= 1 ? 0 : carousel_gap }}"
			data-center-slides="{{ center_slides | default(false) ? 'true' : 'false' }}"
			style="--brand-logo-gap: {{ carousel_gap }}px;">
			<div class="swiper-wrapper">
				{% for logo in logo_blocks %}
					<div class="swiper-slide brand-logo-slide">
						{% include 'blocks/brand-logo.tpl' with { block: logo, logo_size: logo_size, logo_index: loop.index0 } %}
					</div>
				{% endfor %}
			</div>
		</div>

		{% if visible_logo_count > 1 %}
			<button type="button" class="js-carousel-prev swiper-button-prev swiper-button-outside" aria-label="{{ 'general.previous' | t }}">
				<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
			</button>
			<button type="button" class="js-carousel-next swiper-button-next swiper-button-outside" aria-label="{{ 'general.next' | t }}">
				<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
			</button>
		{% endif %}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.brands",
  "icon": "FolderIcon",
  "limit": 1,
  "deletable": false,
  "blocks": [
    { "type": "brand-logo" }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "logo_size",
      "label": "t:settings.logo_size",
      "min": 40,
      "max": 200,
      "step": 4,
      "unit": "px",
      "default": 80,
      "icon": "SizeWidthIcon"
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
    }
  ]
}
{% endschema %}
