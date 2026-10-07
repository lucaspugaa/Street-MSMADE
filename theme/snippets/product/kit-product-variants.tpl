{# Kit component variant pickers (PDP). #}
{# line, data_component and component_index are inherited from the caller's kit-line loop. #}
{% set data_component = data_component ?? 'kit-breakdown' %}
{% set component_index = component_index ?? loop.index0 %}
{% set use_bullet_variants = settings.variant_format == 'buttons' %}
{% set use_image_color_variants = settings.image_color_variants %}
<div class="product-kit-variations" data-kit-component-index="{{ component_index }}" data-component="{{ data_component }}.item-variations">
	{% for variation in line.variations %}
		{% set is_color = variation.name in ['Color', 'Cor'] %}
		{% set is_button_variant = use_bullet_variants or (use_image_color_variants and is_color) %}
		{# This condition handles the selection of kit variants when a hash is provided via the query string (`?c=hash`); if the hash is invalid or nonexistent, the default behavior applies without affecting the PDP flow. #}
		{% set selected_id = line.selected_option_for(loop.index0, variation.options[0].id) %}
		{% set selected_label = (variation.options | filter(option => option.id == selected_id) | first).name | default(variation.options[0].name) %}
		<div class="product-kit-variation-group">
			<div class="form-group {% if is_button_variant %}d-none{% endif %}">
				<label class="form-label">{{ variation.name }}</label>
				<select class="js-kit-component-variation-select form-select" data-variation-id="{{ loop.index0 }}" aria-label="{{ variation.name }}" data-component="{{ data_component }}.item-variation-select">
					{% for option in variation.options %}
						<option value="{{ option.id }}" {% if option.id == selected_id %}selected{% endif %} data-option="{{ option.id }}">{{ option.name }}</option>
					{% endfor %}
				</select>
				<div class="form-select-icon">
					<svg class="form-select-arrow icon-inline"><use xlink:href="#chevron-down"/></svg>
				</div>
			</div>
			{% if is_button_variant %}
				<label class="form-label">{{ variation.name }}: <strong class="js-kit-variation-label" data-variation-id="{{ loop.index0 }}">{{ selected_label }}</strong></label>
				{% for option in variation.options %}
					<a class="js-kit-component-variant btn btn-variant {% if is_color and (option.custom_data or use_image_color_variants) %}btn-variant-color{% endif %} {% if option.id == selected_id %}selected{% endif %}" title="{{ option.name }}" data-name="{{ option.name }}" data-option="{{ option.id }}" data-variation-id="{{ loop.parent.loop.index0 }}" data-component="{{ data_component }}.item-variation-option" data-component-value="{{ option.id }}">
						<span class="btn-variant-content {% if use_image_color_variants and is_color %}btn-variant-content-square{% endif %}" {% if is_color and option.custom_data and not use_image_color_variants %}style="background: {{ option.custom_data }}; border: 1px solid #eee"{% endif %} data-name="{{ option.name }}">
							{% if use_image_color_variants and is_color and option.image %}
								{% include 'snippets/image.tpl' with {
									image_src: option.image,
									product_image: true,
									image_lazy_js: true,
									image_classes: 'img-absolute-centered-vertically fade-in',
									image_thumbs: ['thumb', 'small'],
								} %}
							{% elseif not is_color or (not option.custom_data and not use_image_color_variants) %}
								{{ option.name }}
							{% endif %}
						</span>
					</a>
				{% endfor %}
			{% endif %}
		</div>
	{% endfor %}
</div>
