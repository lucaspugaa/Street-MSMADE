{#
  Blog Post Item
  Renders a single blog post item with thumbnail, title, summary, and read more link.
#}
{% set post_url = '/blog/posts/' ~ post.handle %}
{% set image_alt = post.title %}

<div class="post-item" data-post-id="{{ post.post_id }}" data-component="post-item-{{ post.post_id }}" data-component-value="{{ post.post_id }}">
    {% if post.thumbnail %}
        <div class="post-item-image-container">
            {% if image_container_spacing %}
                <div style="padding-bottom: {{ image_container_spacing_value }}%;">
            {% endif %}
                    <a href="{{ post_url }}" title="{{ post.title }}" aria-label="{{ post.title }}">
                        {% include 'snippets/image.tpl' with {
                            image_src: post.thumbnail,
                            image_alt: image_alt,
                            post_image: true,
                            image_lazy: true,
                            image_lazy_js: true,
                            image_sizes: '(min-width: 768px) 50vw, 100vw',
                            image_classes: 'post-item-image img-absolute img-absolute-centered fade-in',
                        } %}
                    </a>
            {% if image_container_spacing %}
                </div>
            {% endif %}
        </div>
    {% endif %}
    <div class="post-item-information">
        <a href="{{ post_url }}" title="{{ post.title }}" aria-label="{{ post.title }}" class="post-item-link">
            <div class="post-item-title">{{ post.title }}</div>
            <div class="post-item-summary">{{ post.summary }}</div>
            <div class="post-item-read-more btn-link">{{ 'blog.read_more' | t }}</div>
        </a>
    </div>
    {% include 'snippets/structured-data/structured-data.tpl' with {'blog_item': true} %}
</div>
