{#
  Logo Image
  Store logo image with dimensions.
#}
{% set logo_dimensions = store.logo_dimensions() %}
{% set logo_thumbnail = logo_size ? logo_size : 'medium' %}

<div id="logo" class="logo-img-container">
    <a href="{{ store.url }}">
        {% include 'snippets/image.tpl' with {
            logo_image: true,
            image_src: store.logo(logo_thumbnail),
            image_alt: store.name,
            image_classes: 'logo-img',
            image_width: logo_dimensions.width,
            image_height: logo_dimensions.height,
            image_thumbs: ['medium', 'large', 'huge'],
        } %}
    </a>
    {% if template == 'home' %}
        <h1 style="display: none;">{{ store.name }}</h1>
    {% endif %}
</div>
