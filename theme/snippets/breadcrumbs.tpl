{#
  Breadcrumbs
  Breadcrumb navigation for category, cart, blog, search, and error pages.
#}
{% set crumb_separator = '>' %}
{% set crumb_order_name = is_subscription ? subscription.id : 'breadcrumbs.order_number' | t | replace('{1}', order.number) %}
{% set crumb_name =
	template == 'page' ? page.name :
	template == 'cart' ? 'breadcrumbs.cart' | t :
	template == 'blog' ? 'breadcrumbs.blog' | t :
	template == 'blog-post' ? post.title :
	template == 'search' ? 'breadcrumbs.search_results' | t :
	template == '404' ? 'breadcrumbs.error' | t :
	template == 'account/order' ? crumb_order_name
%}
<div class="breadcrumbs">
	<a class="crumb" href="{{ store.url }}" title="{{ store.name }}">{{ 'breadcrumbs.home' | t }}</a>
	<span class="separator">{{ crumb_separator }}</span>
	{% if crumb_name %}
		{% if template == 'blog-post' %}
			<a class="crumb" href="{{ store.blog_url }}" title="{{ 'breadcrumbs.blog' | t }}">{{ 'breadcrumbs.blog' | t }}</a>
			<span class="separator">{{ crumb_separator }}</span>
		{% endif %}
		<span class="crumb active">{{ crumb_name }}</span>
	{% else %}
		{% for crumb in breadcrumbs %}
			{% if crumb.last %}
				<span class="crumb active">{{ crumb.name }}</span>
			{% else %}
				<a class="crumb" href="{{ crumb.url }}" title="{{ crumb.name }}">{{ crumb.name }}</a>
				<span class="separator">{{ crumb_separator }}</span>
			{% endif %}
		{% endfor %}
	{% endif %}
</div>
