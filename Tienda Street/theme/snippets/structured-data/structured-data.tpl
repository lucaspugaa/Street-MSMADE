{#
	Structured Data
	Renders schema.org JSON-LD for the current page (Product, BlogPosting, Blog, or WebPage with breadcrumbs).
	Variants are selected by the optional `item` and `blog_item` flags or the page `template`.
#}
{% macro escape_text(text) %}
{{- text | replace('\\', '\\\\') | replace('"', '\"') | replace('</script', '<\\/script') | replace('\r\n', ' ') | replace('\n', ' ') | replace('\r', ' ') | replace('\t', ' ') -}}
{% endmacro %}

{# Calculate subscription price for subscription only products - computed once for both item and product page #}
{% if item or template == 'product' %}
	{% set is_subscription_only = product.isSubscribable() and product.isSubscriptionOnly() %}
	{% set product_original_price = product.compare_at_price ? product.compare_at_price : product.price %}
	{% set structured_data_price = product_original_price %}

	{% if is_subscription_only %}
		{% set subscription_data = product.getSubscriptionData() %}
		{% set subscription_discount = subscription_data.getMaxDiscountAvailableForSubscription() %}
		{% set combines_with_price_discounts = subscription_data.combinesWithPriceDiscounts() %}
		{% set product_has_price_discount = product.compare_at_price and product.compare_at_price > product.price %}

		{% if combines_with_price_discounts and product_has_price_discount %}
			{# CASE: Combined discounts - apply BOTH discounts on the base price #}
			{% set product_discount_percentage = ((product.compare_at_price - product.price) / product.compare_at_price) * 100 %}
			{% set product_discount_amount = product_original_price * (product_discount_percentage / 100) %}
			{% set subscription_discount_amount = subscription_discount ? (product_original_price * (subscription_discount / 100)) : 0 %}
			{% set structured_data_price = product_original_price - product_discount_amount - subscription_discount_amount %}
		{% elseif subscription_discount %}
			{# CASE: Only subscription discount #}
			{% set structured_data_price = product_original_price * (1 - subscription_discount/100) %}
		{% endif %}
	{% endif %}
{% endif %}

{% if item and not product.is_unlisted %}
	<script type="application/ld+json" data-component='structured-data.item'>
	{
		"@context": "https://schema.org/",
		"@type": "Product",
		"mainEntityOfPage": {
			"@type": "WebPage",
			"@id": "{{ product.canonical_url }}"
		},
		"name": "{{ product.name | replace('"', '\"') }}",
		"image": "{{ 'https:' ~ product.featured_image | product_image_url('large') }}",
		"description": "{{ _self.escape_text(product.seo_description) }}",
		{% if store_has_replace_sku_microdata_tag %}
		"productID": "{{ product.get_product_variant_meta_content_id(store_has_preexisting_meta_catalog_tag, store_has_meta_track_product_groups_tag) | replace('"', '\"') }}",
		{% elseif product.sku %}
		"sku": "{{ product.sku }}",
		{% endif %}
		{% if product.brand %}
			"brand": {
				"@type": "Thing",
				"name": "{{ product.brand | replace('"', '\"') }}"
			},
		{% endif %}
		{% if product.weight %}
			"weight": {
				"@type": "QuantitativeValue",
				"unitCode": "{{ product.weight_unit | iso_to_uncefact }}",
				"value": "{{ product.weight }}"
			},
		{% endif %}
		"offers": {
			"@type": "Offer",
			"url": "{{ product.canonical_url }}",
			"priceCurrency": "{{ product.currency }}",
			"price": "{{ structured_data_price / 100 }}",
			{% if product.stock_control %}
				"availability": "http://schema.org/{{ product.stock ? 'InStock' : 'OutOfStock' }}",
				"inventoryLevel": {
					"@type": "QuantitativeValue",
					"value": "{{ product.stock }}"
				},
			{% endif %}
			"seller": {
				"@type": "Organization",
				"name": "{{ store.name | replace('"', '\"') }}"
			}
		}
	}
	</script>
{% elseif blog_item %}
		<script type="application/ld+json" data-component='structured-data.blog-post'>
		{
			"@context" : "http://schema.org",
			"@type" : "BlogPosting",
			"headline" : "{{ post.seo_title }}",
		{% if post.author_name %}
			"author" : "{{ post.author_name }}",
		{% endif %}
			"description": "{{ _self.escape_text(post.seo_description) }}",
				"url": "{{ store.url }}/blog/posts/{{ post.handle }}",
				"mainEntityOfPage": {
					"@type": "WebPage",
					"@id": "{{ store.url }}/blog/posts/{{ post.handle }}"
				},
				"datePublished" : "{{ post.published_at }}",
				"dateModified" : "{{ post.updated_at }}",
				"publisher" : {
					"@type" : "Organization",
					"name" : "{{ store.name | replace('"', '\"') }}"
				}
		{% if post.thumbnail %}
			,"image" : {
				"@type" : "ImageObject",
				"url" : "{{ post.thumbnail }}"
			}
		{% endif %}
		}
	</script>
{% elseif template == 'blog' %}
	<script type="application/ld+json" data-component='structured-data.blog'>
		{
			"@context": "https://schema.org/",
			"@type": "Blog",
			"@id": "{{ page_info.canonical_url }}",
			"mainEntityOfPage": "{{ page_info.canonical_url }}",
			"name": "{{ page_title }}",
			"description": "{{ _self.escape_text(page_description) }}",
			"publisher": {
				"@type": "Organization",
				"name": "{{ store.name | replace('"', '\"') }}"
			},
			"blogPost": [
			{% for post in blog.posts %}
			{
				"@type" : "BlogPosting",
				"headline" : "{{ post.seo_title }}",
				{% if post.author_name %}
					"author" : "{{ post.author_name }}",
				{% endif %}
				"description": "{{ _self.escape_text(post.seo_description) }}",
					"url": "{{ store.url }}/blog/posts/{{ post.handle }}",
					"mainEntityOfPage": {
						"@type": "WebPage",
						"@id": "{{ store.url }}/blog/posts/{{ post.handle }}"
					},
					"datePublished" : "{{ post.published_at }}",
					"dateModified" : "{{ post.updated_at }}",
					"publisher" : {
						"@type" : "Organization",
						"name" : "{{ store.name | replace('"', '\"') }}"
					}
				{% if post.thumbnail %}
					,"image" : {
						"@type" : "ImageObject",
						"url" : "{{ post.thumbnail }}"
					}
				{% endif %}
			}{% if loop.index != loop.length %},{% endif %}
			{% endfor %}
		  ]
	  }
	</script>
{% elseif not item %}
	<script type="application/ld+json" data-component='structured-data.page'>
	{
		"@context": "https://schema.org/",
		"@type": "WebPage",
		"name": "{{ page_title | replace('"', '\"') }}",
		{% if page_description %}
			"description": "{{ _self.escape_text(page_description) }}",
		{% endif %}
		"breadcrumb": {
			"@type": "BreadcrumbList",
			"itemListElement": [
			{
				"@type": "ListItem",
				"position": 1,
				"name": "{{ 'breadcrumbs.home' | t }}",
				"item": "{{ store.url }}"
			}{% if template != 'home' %},{% endif %}
			{% if template == 'page' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ page.name | replace('"', '\"') }}",
					"item": "{{ page.url }}"
				}
			{% elseif template == 'cart' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.cart' | t }}",
					"item": "{{ store.url }}{{ store.cart_url }}"
				}
			{% elseif template == 'search' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.search_results' | t }}",
					"item": "{{ store.url }}{{ store.search_url }}"
				}
			{% elseif template == 'account.order' %}
				{
					"@type": "ListItem",
					"position": 2,
					"name": "{{ 'breadcrumbs.order_number' | t | replace('{1}', order.number) }}",
					"item": "{{ store.url }}{{ store.customer_order_url(order) }}"
				}
			{% else %}
				{% for crumb in breadcrumbs %}
					{
						"@type": "ListItem",
						"position": {{ loop.index + 1 }},
						"name": "{{ crumb.name | replace('"', '\"') }}",
						"item": "{{ store.url }}{{ crumb.url }}"
					}{% if not crumb.last %},{% endif %}
				{% endfor %}
			{% endif %}
			]
		}{% if template == 'product' and not product.is_unlisted %},
		"mainEntity": {
			"@type": "Product",
			"@id": "{{ product.canonical_url }}",
			"name": "{{ product.name | replace('"', '\"') }}",
			"image": "{{ 'https:' ~ product.featured_image | product_image_url('large') }}",
			"description": "{{ _self.escape_text(page_description) }}",
			{% if store_has_replace_sku_microdata_tag %}
			"productID": "{{ product.get_product_variant_meta_content_id(store_has_preexisting_meta_catalog_tag, store_has_meta_track_product_groups_tag) | replace('"', '\"') }}",
			{% elseif product.sku %}
			"sku": "{{ product.sku }}",
			{% endif %}
			{% if product.brand %}
				"brand": {
					"@type": "Thing",
					"name": "{{ product.brand | replace('"', '\"') }}"
				},
			{% endif %}
			{% if product.weight %}
				"weight": {
					"@type": "QuantitativeValue",
					"unitCode": "{{ product.weight_unit | iso_to_uncefact }}",
					"value": "{{ product.weight }}"
				},
			{% endif %}
			"offers": {
				"@type": "Offer",
				"url": "{{ product.canonical_url }}",
				"priceCurrency": "{{ product.currency }}",
				"price": "{{ structured_data_price / 100 }}",
				{% if product.stock_control %}
					"availability": "http://schema.org/{{ product.stock ? 'InStock' : 'OutOfStock' }}",
					"inventoryLevel": {
						"@type": "QuantitativeValue",
						"value": "{{ product.stock }}"
					},
				{% endif %}
				"seller": {
					"@type": "Organization",
					"name": "{{ store.name | replace('"', '\"') }}"
				}
			}
		}
		{% endif %}
	}
	</script>
{% endif %}
