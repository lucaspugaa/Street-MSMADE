{#
  Products Section
  Renders a product grid/slider with title and navigation controls.
  Used by related products, cart related products, and timer offers.
#}
{% set slider = slider ?? true %}

{% set slider_controls %}
	{% if slider_controls_container %}
		<div class="products-section-slider-controls-container {{ section_classes.slider_controls_container }}">
	{% endif %}
			{% if slider_direction_controls_container %}
				<div class="products-section-slider-direction-controls-container {{ section_classes.slider_direction_controls_container }}">
			{% endif %}
					<div class="products-section-prev-container {{ section_classes.slider_control_prev_container }}">
						<svg class="products-section-slider-control products-section-slider-control-prev slider-arrow slider-arrow-prev icon-inline {{ section_classes.slider_control_prev }}">
							<use xlink:href="#arrow-long"/>
						</svg>
					</div>
					{% if slider_pagination and not slider_direction_controls_container %}
						<div class="products-section-slider-controls-pagination {{ section_classes.slider_control_pagination }}"></div>
					{% endif %}
					<div class="products-section-next-container {{ section_classes.slider_control_next_container }}">
						<svg class="products-section-slider-control products-section-slider-control-next slider-arrow icon-inline {{ section_classes.slider_control_next }}">
							<use xlink:href="#arrow-long"/>
						</svg>
					</div>
			{% if slider_direction_controls_container %}
				</div>
				{% if slider_pagination %}
					<div class="products-section-slider-controls-pagination {{ section_classes.slider_control_pagination }}"></div>
				{% endif %}
			{% endif %}
	{% if slider_controls_container %}
		</div>
	{% endif %}
{% endset %}

<section id="{{ id }}" class="products-section {{ section_classes.section }}" data-store="{{ id }}" data-component="{{ data_component }}" data-related-amount="{{ products_amount }}">
	<div class="{{ section_classes.container }}">
		{% if title or slider_controls_position == 'with-section-title' %}
			<div class="products-section-title-container {{ section_classes.title_container }}">
				<h2 class="products-section-title {{ section_classes.title }}">{{ title }}</h2>
				{% if slider and slider_controls_position == 'with-section-title' %}
					{{ slider_controls }}
				{% endif %}
			</div>
		{% endif %}
		<div class="products-section-container {{ section_classes.products_container }}">
			{% if slider %}
				<div class="products-section-slider-container {{ section_classes.slider_container }}">
					<div class="products-section-slider-wrapper {{ section_classes.slider_wrapper }}">
			{% endif %}
						{% for product in products_array %}
							{% include product_template_path with product_template_params %}
						{% endfor %}
			{% if slider %}
					</div>
				</div>
				{% if slider_controls_position == 'bottom' %}
					{{ slider_controls }}
				{% endif %}
			{% endif %}
		</div>
	</div>
</section>
