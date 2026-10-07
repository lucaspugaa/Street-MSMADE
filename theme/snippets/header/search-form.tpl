{% set placeholder_text = placeholder_text ? placeholder_text : 'search.placeholder' | t %}
{% set submit_text = submit_text ? submit_text : 'search.value' | t %}
{% set use_delete_btn = use_delete_btn ?? true %}

<div class="search-form-wrap">
	<form class="js-search-form search-form" action="{{ store.search_url }}" method="get">
		<div class="search-form-field form-group">
			<input class="js-search-input form-control search-input input_class" autocomplete="off" type="search" name="q" placeholder="{{ placeholder_text }}" aria-label="{{ placeholder_text }}" />
			<button type="submit" class="{% if use_delete_btn %}js-search-input-submit{% endif %} search-btn search-submit-btn" value="{{ 'search.value' | t }}" aria-label="{{ 'search.value' | t }}">
				{% if use_submit_text %}
					{{ submit_text }}
				{% else %}
					{% include 'snippets/icon.tpl' with { name: 'search', size: 16 } %}
				{% endif %}
			</button>
			{% if use_delete_btn %}
				<button type="button" class="js-empty-search search-btn search-empty-btn" aria-label="{{ 'search.placeholder' | t }}" style="display: none;">
					<svg class="icon-inline"><use xlink:href="#times"/></svg>
				</button>
			{% endif %}
		</div>
	</form>
	<div class="js-search-form-suggestions search-suggestions" style="display: none;">
		{# AJAX container for search suggestions #}
	</div>
</div>
