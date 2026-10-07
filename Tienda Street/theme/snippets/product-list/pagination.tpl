{#
  Pagination
  Page navigation: load-more button or prev/next links.
#}
{% if infinite_scroll %}
	{% if pages.current == 1 and not pages.is_last %}
		<div class="js-load-more pagination-load-more">
			<a class="btn btn-primary">
				{{ 'general.show_more_products' | t }}
				<span class="js-load-more-spinner pagination-load-more-spinner" style="display:none;">
					<svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
				</span>
			</a>
		</div>
		<div id="js-infinite-scroll-spinner" class="pagination-spinner" style="display:none">
			<svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
		</div>
	{% endif %}
{% else %}
	{% if pages.numbers %}
		<div class="pagination-nav">
			<a {% if pages.previous %}href="{{ pages.previous }}"{% endif %} class="pagination-arrow pagination-arrow-prev {% if not pages.previous %}opacity-30 disabled{% endif %}">
				<svg class="slider-arrow slider-arrow-prev icon-inline"><use xlink:href="#arrow-long"/></svg>
			</a>
			<div class="pagination-counter">
				{% for page in pages.numbers %}
					{% if page.selected %}
						<span>{{ page.number }}</span>
					{% endif %}
				{% endfor %}
				<span>/</span>
				<span>{{ pages.amount }}</span>
			</div>
			<a {% if pages.next %}href="{{ pages.next }}"{% endif %} class="pagination-arrow {% if not pages.next %}opacity-30 disabled{% endif %}">
				<svg class="slider-arrow icon-inline"><use xlink:href="#arrow-long"/></svg>
			</a>
		</div>
	{% endif %}
{% endif %}
