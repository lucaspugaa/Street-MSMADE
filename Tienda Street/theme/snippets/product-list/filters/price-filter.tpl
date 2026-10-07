{#
  Price Filter
  Min/max price range filter for product grid.
#}
<div class="js-price-filter-container {{ accordion ? 'price-filter-container filter-accordion' : 'price-filter-container' }}" data-store="filters-group" data-component="list.filter-price">
	<form>
		<div class="{{ accordion ? 'price-filter-label' : 'filters-title' }}">{{ 'filters.price.label' | t }}</div>
		<div class="form-group">
			<span class="js-filter-input-price-container filter-input-price-container">
				<label class="form-label">{{ 'filters.price.from' | t }}</label>
				<input
					type="number"
					name="min_price"
					step="1" min="0"
					pattern="\d*"
					oninput="validity.valid||(value='');"
					class="js-price-filter-input form-control filter-input-price"
					data-component="list.filter-price.min"
					value="{{ params['min_price'] }}"
					placeholder="{{ product_filter.custom_data.price_range['min_price'] }}"
				>
				<a class="js-price-filter-empty input-clear-content" style="display:none" aria-label="{{ 'general.clear' | t }}">
						<svg class="icon-inline"><use xlink:href="#times"/></svg>
				</a>  
			</span>
			<span class="js-filter-input-price-container filter-input-price-container">
				<label class="form-label">{{ 'filters.price.to' | t }}</label>
				<input
					type="number"
					name="max_price"
					step="1" min="0"
					pattern="\d*"
					oninput="validity.valid||(value='');"
					class="js-price-filter-input form-control filter-input-price"
					data-component="list.filter-price.max"
					value="{{ params['max_price'] }}"
					placeholder="{{ product_filter.custom_data.price_range['max_price'] }}"
				>
				<a class="js-price-filter-empty input-clear-content" style="display:none" aria-label="{{ 'general.clear' | t }}">
						<svg class="icon-inline"><use xlink:href="#times"/></svg>
				</a>
			</span>
			<button type="submit" class="js-price-filter-btn btn btn-inline price-filter-btn disabled" disabled data-component="list.filter-price.submit">
				{{ 'filters.price.apply' | t }}
				{% if not accordion %}
					<svg class="price-filter-btn-icon icon-inline"><use xlink:href="#chevron"/></svg>
				{% endif %}
			</button>
		</div>
	</form>
</div>
