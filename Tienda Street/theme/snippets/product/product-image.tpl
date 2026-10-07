{# Get settings from block_settings passed from main-product section #}
{% set bs = block_settings ?? {} %}
{% set show_thumbnails = bs.show_thumbnails ?? true %}
{% set thumbnail_position = bs.thumbnail_position | default('left') %}
{% set format = bs.format | default('slider') %}
{% set columns = bs.columns | default('1') %}
{% set columns_class = columns | replace('_', '-') %}
{% set gap = bs.gap | default(16) %}
{% set is_grid = format == 'grid' %}
{% set grid_desktop_hidden_class = is_grid ? ' d-md-none' %}

{# For home_main_product: no video, no fancybox #}
{% if home_main_product %}
  {% set has_multiple_slides = product.media_count > 1 %}
{% else %}
  {% set has_multiple_slides = product.media_count > 1 or product.video_url %}
{% endif %}
{% set show_thumbs = show_thumbnails and has_multiple_slides %}

{% if product.media_count > 0 %}
		{# Placeholder products skip labels, nubesdk slots, and fancybox — those need a real product. #}
		{% set is_placeholder = product.isPlaceholder() %}
		{% set disable_link = home_main_product or is_placeholder %}

		<div class="w-100 order-md-first">
			{{ component('nubesdk-slot', { type: "before_product_detail_image" }) }}
		</div>

		<div class="product-images-slider {% if is_grid %}product-images-grid product-images-grid-columns-{{ columns_class }}{% endif %}" {% if is_grid %}data-gallery-format="grid" style="--product-images-grid-gap: {{ gap }}px;"{% endif %}>
			{% if not is_placeholder %}
				{% include 'snippets/labels.tpl' with {
						no_stock_only: true,
						labels_classes: {
							group: 'product-labels',
						},
					}
				%}

				{{ component('nubesdk-slot', { type: "product_detail_image" }) }}
			{% endif %}

			<div class="js-product-slider swiper-container" data-product-images-amount="{{ product.media_count }}">
				<div class="swiper-wrapper">
					{% for media in product.media %}
						{% if media.isImage %}
							<div class="js-product-slide swiper-slide slider-slide" data-image="{{ media.id }}" data-image-position="{{ loop.index0 }}">
								{% if disable_link %}
								<div class="js-product-slide-link product-slide-link" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100 }}%;">
							{% else %}
								<a href="{{ media | product_image_url('4k') }}" data-fancybox="product-gallery" class="js-product-slide-link product-slide-link" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100 }}%;">
								{% endif %}
									{# First image on PDP gets priority, rest use Swiper lazy #}
									{% set is_priority = not home_main_product and loop.first %}
									{% include 'snippets/image.tpl' with {
										image_priority_high: is_priority,
										image_src: media,
										image_width: media.dimensions.width,
										image_height: media.dimensions.height,
										image_classes: 'js-product-slide-img product-slider-image img-absolute img-absolute-centered' ~ (not is_priority ? ' fade-in'),
										image_alt: media.alt,
										product_image: not is_placeholder,
										image_lazy_js: not is_priority,
										image_swiper_lazy_class: not is_priority and not is_grid,
									} %}
									{% if not is_priority %}
										<div class="placeholder placeholder-fade"></div>
									{% endif %}
								{% if disable_link %}
									</div>
								{% else %}
									</a>
								{% endif %}
							</div>
						{% else %}
							{# Native video slide #}
							{% include 'snippets/product/product-video.tpl' with {product_native_video: true, video_id: media.next_video, home_main_product: home_main_product} %}
						{% endif %}
					{% endfor %}
					{% if not home_main_product and product.video_url %}
						{# YouTube/Vimeo video slide #}
						{% include 'snippets/product/product-video.tpl' %}
					{% endif %}
				</div>
				
				{# Main slider arrows - shown only on desktop when thumbnails are hidden #}
				{% if has_multiple_slides and not show_thumbs %}
					<button type="button" class="js-product-slider-prev swiper-button-prev swiper-product-arrow swiper-product-arrow-prev {{ grid_desktop_hidden_class }}" aria-label="{{ 'general.previous' | t }}">
						<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
					<button type="button" class="js-product-slider-next swiper-button-next swiper-product-arrow swiper-product-arrow-next {{ grid_desktop_hidden_class }}" aria-label="{{ 'general.next' | t }}">
						<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
					</button>
				{% endif %}
			</div>
			{% if has_multiple_slides %}
				<div class="js-product-slider-pagination swiper-fractions text-right {{ grid_desktop_hidden_class }}"></div>
			{% endif %}
		</div>
		{% if show_thumbs %}
			<div class="js-product-images-thumbs product-images-thumbs {% if thumbnail_position == 'bottom' %}order-md-last product-images-thumbs-horizontal{% else %}order-md-first{% endif %} {{ grid_desktop_hidden_class }} text-md-center">
				<div class="js-product-slider-thumbs swiper-product-thumb product-slider-thumbs" data-direction="{{ thumbnail_position == 'bottom' ? 'horizontal' : 'vertical' }}">
					<div class="swiper-wrapper">
						{% for media in product.media %}
							<div class="swiper-slide product-thumb-container">
								{% include 'snippets/product/product-image-thumbs.tpl' %}
							</div>
						{% endfor %}
						{% if not home_main_product and product.video_url %}
							{# YouTube/Vimeo video thumbnail #}
							<div class="swiper-slide product-thumb-container">
								{% include 'snippets/product/product-video.tpl' with { thumb: true } %}
							</div>
						{% endif %}
					</div>
				</div>
		<button type="button" class="js-product-slider-thumbs-prev swiper-button-prev swiper-button-inline slider-arrow-inline" aria-label="{{ 'general.previous' | t }}">
			<svg class="thumb-arrow-prev icon-inline"><use xlink:href="#arrow-long-down"/></svg>
		</button>
		<button type="button" class="js-product-slider-thumbs-next swiper-button-next swiper-button-inline slider-arrow-inline" aria-label="{{ 'general.next' | t }}">
			<svg class="thumb-arrow-next icon-inline"><use xlink:href="#arrow-long-down"/></svg>
		</button>
			</div>
		{% endif %}

		<div class="w-100 order-md-last">
			{{ component('nubesdk-slot', { type: "after_product_detail_image" }) }}
		</div>
{% endif %}
