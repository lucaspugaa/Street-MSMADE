{#
  Blog Post Content
  Renders blog post date, thumbnail image, and content.
#}
{% set image_alt = post.title %}
{% set published_date = 'blog.published_at' | t ~ ' ' ~ (post.created_at | date('d/m/Y')) %}
{% if post.author_name is not empty %}
    {% set published_date = published_date ~ ' ' ~ 'blog.by' | t ~ ' ' ~ post.author_name %}
{% endif %}

<p class="post-date">{{published_date}}</p>
{% if post.thumbnail %}
    {% include 'snippets/image.tpl' with {
        image_src: post.thumbnail,
        image_alt: image_alt,
        post_image: true,
        image_lazy: true,
        image_lazy_js: true,
        image_sizes: '(min-width: 768px) 50vw, 100vw',
        image_classes: 'post-content-image post-item-image img-fluid fade-in',
    } %}
{% endif %}
<div class="post-content">{{ post.content }}</div>
