<label class="js-radio-button-private radio-button radio-button-accent {{ label_classes }}"
	{% if loop_id %}data-loop="{{ loop_id }}-{{ loop.index }}"{% endif %}
	{% if label_data_attributes %}
		{% for attr, value in label_data_attributes %}data-{{ attr }}="{{ value }}"{% endfor %}
	{% endif %}>
	<input
		id="{{ id }}"
		class="js-radio-button-private {{ input_classes }}"
		type="radio"
		value="{{ value }}"
		{% if checked %}checked="checked"{% endif %}
		{% if name %}
		name="{{ name }}"
		{% endif %}
		style="display:none"
		{% if input_data_attributes %}
			{% for attr, value in input_data_attributes %}data-{{ attr }}="{{ value }}"{% endfor %}
		{% endif %} />

	<div class="radio-button-content">
		<div class="radio-button-icons-container">
			<span class="radio-button-icon unchecked radio-button-icons"></span>
			<span class="radio-button-icon checked radio-button-icons"></span>
		</div>
		<div class="radio-button-label">
			{% if radio_button_custom_content %}
				{{ radio_button_custom_content | raw }}
			{% else %}
				<div class="radio-button-text d-grid grid-1-auto">
					{{ radio_button_text }}
				</div>
			{% endif %}
		</div>
	</div>
</label>
