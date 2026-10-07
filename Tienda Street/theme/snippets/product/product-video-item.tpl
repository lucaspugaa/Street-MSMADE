{#
  Product Video Item
  Single product video block: YouTube/native embed or thumbnail with play button.
#}
{% if not product_native_video and product.video_url %}
	{% set video_url = product.video_url %}

	{# Convert YouTube URL to embed format #}
	{% set youtube_id = video_url | split('v=') | last | split('&') | first %}
	{% if 'youtu.be' in video_url %}
		{% set youtube_id = video_url | split('youtu.be/') | last | split('?') | first %}
	{% endif %}
	{% set youtube_thumb_url = 'https://img.youtube.com/vi/' ~ youtube_id ~ '/mqdefault.jpg' %}
{% endif %}

{% if thumb %}
	<div class="video-player-icon video-player-icon-small">
		<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
	</div>
	{% include 'snippets/image.tpl' with {
		image_src: product_native_video ? media.thumbnail : youtube_thumb_url,
		image_alt: 'product.video_of' | t ~ ' ' ~ product.name,
		image_classes: 'img-absolute img-absolute-centered',
		image_thumbs: false,
	} %}
{% else %}
	{% if product_modal %}
		{# Hidden video player shown inside Fancybox on mobile #}
		<div id="product-video-modal-{{ media.id }}" class="js-product-video-modal product-video-modal product-video" style="display: none;">
	{% endif %}
			{% set is_external_video = not product_native_video %}
			{% set is_standalone_video = product_video and not product_modal %}
			{% set is_native_video_home = product_native_video and home_main_product %}

			<div class="{% if is_external_video %}js-video{% endif %} {% if is_standalone_video %}js-video-product{% endif %} embed-responsive embed-responsive-16by9 product-video-embed {% if product_native_video %}product-native-video-container{% if is_native_video_home %} product-native-video-home{% endif %}{% endif %}">

				{% if product_modal_trigger %}
					{# Open modal in mobile with product video inside #}
					<a id="trigger-video-modal-{{ media.id }}" href="#product-video-modal-{{ media.id }}" data-fancybox="product-gallery" class="js-play-button js-product-video-link video-player {% if not home_main_product %}d-block d-md-none{% endif %} {% if home_main_product %}d-none{% endif %}" {% if not product_native_video %}data-video-url="{{ video_url }}"{% endif %}>
						<div class="video-player-icon">
							<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
						</div>
					</a>
				{% endif %}
				{% set play_button_class = product_native_video ? 'js-play-native-button' : 'js-play-button' %}
				{% set play_visibility_class = (product_modal_trigger and not home_main_product) ? 'd-none d-md-block' : '' %}
				<a href="javascript:void(0)" {% if product_native_video %}data-video_uid="{{ media.next_video }}"{% endif %} class="{{ play_button_class }} video-player {{ play_visibility_class }}">
					<div class="video-player-icon">
						<svg class="video-play-icon icon-inline"><use xlink:href="#play"/></svg>
					</div>
				</a>

				{# Video thumbnail #}

				{% if product_native_video %}
					<div class="js-video-native-image w-100">
						<div data-video_uid="{{ media.uid }}" class="js-external-video-iframe-container embed-responsive" data-video-color="{{ settings.accent_color | trim('#') }}" style="display:none;">
							{{ media.render | raw }}
						</div>
						{% include 'snippets/image.tpl' with {
							image_src: media.thumbnail,
							image_alt: ('product.video_of' | t) ~ ' ' ~ (template != 'product' ? store.name : product.name),
							image_classes: 'video-image fade-in',
							image_lazy_js: true,
							image_thumbs: false,
							image_data_attributes: { video_uid: media.uid },
						} %}
					</div>
				{% else %}
					<div class="js-video-image video-image">
						{% include 'snippets/image.tpl' with {
							image_src: youtube_thumb_url,
							image_alt: 'product.video_of' | t ~ ' ' ~ product.name,
							image_classes: 'img-fluid fade-in',
							image_lazy_js: true,
							image_thumbs: false,
						} %}
					</div>
				{% endif %}
			</div>

			{% if not product_native_video %}
				{# Iframe container for inline desktop playback, filled by LS.loadVideo on click #}
				{% if product.video_url %}
					<div class="js-video-iframe embed-responsive embed-responsive-16by9" style="display: none;" data-video-url="{{ video_url }}">
					</div>
				{% endif %}
			{% endif %}
	{% if product_modal %}
		</div>
	{% endif %}
{% endif %}
