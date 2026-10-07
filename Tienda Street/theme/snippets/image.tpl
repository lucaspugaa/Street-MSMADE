{#
  Image
  Unified responsive image component. Single entry point: image_src.
  Supports product images, category images, post images, theme editor image_picker settings,
  @media-lib references (from image_picker or metafields), and external URLs.
  Renders as <picture> with AVIF/WebP when srcsets are available.

  Usage:
    image_src          - The image to display (image object, @media-lib ref, or URL).
                         Callers handling metafields must unwrap MetafieldItem.value before passing.
    product_image      - true if image_src is a product image object
    category_image     - true if image_src is a category image object
    post_image         - true if image_src is a post/blog image
    image_thumbs       - Array of thumb sizes for srcset, or false to disable srcset entirely
#}

{# Resolve image objects (product/category/post) into URLs, keeping the object for srcset generation #}
{% if (product_image or category_image or post_image) and image_src %}
	{% set image_name = image_src %}
	{% if product_image %}
		{% set image_src = image_src | product_image_url('large') %}
	{% elseif category_image %}
		{% set image_src = image_src | category_image_url('large') %}
	{% endif %}
{% endif %}

{# Resolve media library references (theme editor image_picker settings or product metafields) into image data with srcsets #}
{% set media = image_src is defined and image_src starts with '@media-lib:' ? (image_src | resolve_media) : null %}

{% if media %}
	{% set image_src = media.sourceUrl %}
	{% if not image_width and not image_height %}
		{% set image_width = media.sourceWidth %}
		{% set image_height = media.sourceHeight %}
	{% endif %}
	{% if not image_alt and media.altText %}
		{% set image_alt = media.altText %}
	{% endif %}
{% endif %}
{% set has_media_library_srcsets = media and media.srcSets | length > 0 %}

{% set image_thumbs =
	image_thumbs is same as(false) ? false :
	image_thumbs ? image_thumbs :
	product_image ? ['tiny', 'thumb', 'small', 'medium', 'large', 'huge', 'original', '1080p', '1440p', '4k'] :
	category_image ? ['tiny', 'thumb', 'small', 'medium', 'large', 'huge', 'original', '1080p'] :
	['tiny', 'thumb', 'small', 'medium', 'large', 'huge', 'original', 'xlarge', '1080p']
%}

{% set sizes = {
	'tiny': 50,
	'thumb': 100,
	'small': 240,
	'medium': 320,
	'large': 480,
	'huge': 640,
	'original': 1024,
	'xlarge': 1400,
	'1080p': 1920,
	'1440p': 2560,
	'4k': 3840
} %}

{% set default_image_url =
	post_image ? image_name :
	product_image ? image_name | product_image_url('large') :
	category_image ? image_name | category_image_url('large') :
	image_src
%}

{% set src = image_src ? image_src : (image_priority_high ? default_image_url : 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==') %}
{% set srcset = '' %}
{% set image_lazy = image_lazy == 'false' ? false : true %}

{# srcset for non-media-library images (products, categories, blog posts, store logo) #}
{% if image_thumbs is not same as(false) and not media %}
	{% for thumb, size in sizes %}
		{% if thumb in image_thumbs %}
			{% set image_url =
				logo_image ? store.logo(thumb) :
				post_image ? image_name :
				product_image ? image_name | product_image_url(thumb) :
				category_image ? image_name | category_image_url(thumb) :
				image_src
			%}
			{% set srcset = srcset ~ (srcset ? ', ' : '') ~ image_url ~ ' ' ~ size ~ 'w' %}
		{% endif %}
	{% endfor %}
{% endif %}

{% set image_lazy = image_lazy and not image_priority_high %}
{% set image_lazy_js = image_lazy_js and not image_priority_high %}

{# Shared <img> attributes used by both branches #}
{% set img_attrs %}
	{% if image_priority_high %}
		fetchpriority="high"
	{% endif %}
	{% if image_width %}
		width="{{ image_width }}"
	{% endif %}
	{% if image_height %}
		height="{{ image_height }}"
	{% endif %}
	{% if image_lazy and not image_lazy_js %}
		loading="lazy"
	{% endif %}
	{% if image_classes or image_lazy_js %}
		class="{% if image_swiper_lazy_class %}swiper-lazy{% elseif image_lazy_js %}lazyload{% endif %}{% if image_priority_high %} image-priority-high{% endif %} {{ image_classes }}"
	{% endif %}
	{% if image_sizes %}
		sizes="{{ image_sizes }}"
	{% endif %}
	{% if image_data_expand %}
		data-expand="{{ image_data_expand }}"
	{% endif %}
	{% if image_data_sizes %}
		data-sizes="{{ image_data_sizes }}"
	{% endif %}
	{% if image_data_attributes %}
		{% for attr, value in image_data_attributes %}data-{{ attr }}="{{ value }}" {% endfor %}
	{% endif %}
	alt="{{ image_alt }}"
{% endset %}

{# Build original-format srcset from theme editor image_picker srcsets so both paths share one <img> #}
{% if has_media_library_srcsets %}
	{% for srcSet in media.srcSets if srcSet.format == 'original' %}
		{% for size in srcSet.sizes %}
			{% set srcset = srcset ~ (srcset ? ', ') ~ srcSet.baseUrl ~ size.w ~ '.' ~ media.extension ~ ' ' ~ size.w ~ 'w' %}
		{% endfor %}
	{% endfor %}
	{% set image_aspect_ratio = true %}
{% endif %}

{# Resolve data-src fallback for non-media images #}
{% set data_src = image_src ? image_src : default_image_url %}

{# @media-lib references with processed thumbnails get <picture> with AVIF/WebP <source> elements.
   Everything else (products, categories, blog, or images still processing) uses a plain <img>.
   Bail when a @media-lib ref resolves to non-image media (e.g. video or orphan uuid from a metafield). #}
{% if not media or media.type == 'image' %}
	{% if has_media_library_srcsets %}
		<picture>
			{% for srcSet in media.srcSets if srcSet.format != 'original' %}
				{% set source_srcset = '' %}
				{% for size in srcSet.sizes %}
					{% set source_srcset = source_srcset ~ (source_srcset ? ', ') ~ srcSet.baseUrl ~ size.w ~ '.' ~ srcSet.format ~ ' ' ~ size.w ~ 'w' %}
				{% endfor %}
				<source
					type="image/{{ srcSet.format }}"
					{% if image_lazy_js %}data-{% endif %}srcset="{{ source_srcset }}"
					{% if image_sizes %}sizes="{{ image_sizes }}"{% endif %}
					{% if image_data_sizes %}data-sizes="{{ image_data_sizes }}"{% endif %}
				/>
			{% endfor %}
	{% endif %}

		<img
			{{ img_attrs }}
			{% if image_lazy_js %}
				{% if image_width and image_height %}src="data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="{% endif %}
				{% if srcset %}
					data-srcset="{{ srcset }}"
				{% else %}
					data-src="{{ data_src }}"
				{% endif %}
			{% else %}
				src="{{ src }}"
				{% if srcset %}srcset="{{ srcset }}"{% endif %}
			{% endif %}
			{% if image_aspect_ratio and image_width and image_height %}
				style="aspect-ratio: {{ image_width }} / {{ image_height }}"
			{% endif %}
		/>

	{% if has_media_library_srcsets %}
		</picture>
	{% endif %}
{% endif %}
