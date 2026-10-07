{#
  Product Image/Video Thumb (unified)
  Single thumbnail in the product gallery, supporting both images and native videos.
#}
<a href="#" {% if media.isVideo %}data-video_id="{{ media.id }}"{% endif %} class="js-product-thumb {% if loop.last and last_open_modal %}js-product-thumb-modal{% endif %} product-thumb {% if loop.first %}selected{% endif %}" style="padding-bottom: {{ media.dimensions['height'] / media.dimensions['width'] * 100}}%;" data-thumb-loop="{{loop.index0}}">
	{% if media.isImage %}
		{% include 'snippets/image.tpl' with {
			image_src: media,
			image_width: media.dimensions.width,
			image_height: media.dimensions.height,
			image_classes: 'img-absolute img-absolute-centered',
			image_alt: media.alt,
			product_image: true,
			image_thumbs: ['thumb', 'small'],
			image_lazy_js: true,
		} %}
	{% else %}
		<div class="video-player-icon video-player-icon-small">
			<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
		</div>
		{% include 'snippets/image.tpl' with {
			image_src: media.thumbnail,
			image_alt: ('product.video_of' | t) ~ ' ' ~ product.name,
			image_classes: 'img-absolute img-absolute-centered lazyautosizes',
			image_lazy_js: true,
			image_thumbs: false,
			image_data_sizes: 'auto',
		} %}
	{% endif %}
</a>
