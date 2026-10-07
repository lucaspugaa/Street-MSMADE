{#
  Sort By
  Product grid sort options (select or list).
#}
{% set sort_text = {
	'score-descending': 'sort_by.options.relevance' | t,
	'user': 'sort_by.options.custom' | t,
	'price-ascending': 'sort_by.options.price_ascending' | t,
	'price-descending': 'sort_by.options.price_descending' | t,
	'alpha-ascending': 'sort_by.options.alpha_ascending' | t,
	'alpha-descending': 'sort_by.options.alpha_descending' | t,
	'created-ascending': 'sort_by.options.created_ascending' | t,
	'created-descending': 'sort_by.options.created_descending' | t,
	'best-selling': 'sort_by.options.best_selling' | t,
} %}

{% set label = label ?? true %}
{% set list_title = list_title ?? true %}

{% if list %}
	{% if list_title %}
		<div class="d-none">{{ 'sort_by.label' | t }}</div>
	{% endif %}
	<ul class="radio-button-container sort-by-options list-unstyled">
		{% for sort_method in sort_methods %}
			{% if sort_method != 'user' or category.sort_method == 'user' %}
				<li class="radio-button-item">
					<a href="#" class="js-apply-sort-private radio-button {% if sort_by == sort_method %}selected{% endif %}" data-sort-value="{{ sort_method }}">
						<div class="radio-button-content">
							<span class="radio-button-icons-container">
								<div class="radio-button-icon unchecked"></div>
								<div class="radio-button-icon checked"></div>
							</span>
							<span class="radio-button-label">
								{{ sort_text[sort_method] }}
							</span>
						</div>
					</a>
				</li>
			{% endif %}
		{% endfor %}
	</ul>

	<div class="js-sorting-overlay-private filters-overlay" style="display: none;">
		<div class="filters-updating-message">
			<span class="filters-updating-text">{{ 'sort_by.feedback.applying' | t }}</span>
			<svg class="icon-loading icon-inline"><use xlink:href="#spinner-third"/></svg>
		</div>
	</div>
{% else %}
	<div class="form-group">
		{% if label %}
			<label class="form-label">{{ 'sort_by.label' | t }}</label>
		{% endif %}
		<select class="js-sort-by-private form-select form-select-small" aria-label="{{ 'sort_by.label' | t }}" data-component="sort-by">
			{% for sort_method in sort_methods %}
				<option value="{{ sort_method }}" {% if sort_by == sort_method %}selected{% endif %}>{{ sort_text[sort_method] }}</option>
			{% endfor %}
		</select>

		<div class="form-select-icon">
			<svg class="form-select-arrow icon-inline"><use xlink:href="#chevron-down"/></svg>
		</div>
	</div>
{% endif %}
