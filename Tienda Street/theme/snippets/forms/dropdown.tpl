{#
  Dropdown
  Custom dropdown component with button, options list, and keyboard/click interaction.
#}
<div class="js-dropdown-private dropdown-custom {{ dropdown_classes.container }}" 
	{% if hidden %}style="display: none;"{% endif %}
	{% if data_attributes %}
		{% for attr, value in data_attributes %}data-{{ attr }}="{{ value }}"{% endfor %}
	{% endif %}>

	{% if dropdown_label %}
		<label class="dropdown-custom-label {{ dropdown_classes.label }}">{{ dropdown_label }}</label>
	{% endif %}

	<button class="js-dropdown-button-private dropdown-custom-button {{ dropdown_classes.button }}">
		<span class="js-dropdown-selected-option-private dropdown-custom-selected-option">
			{{ selected_text }}
		</span>
		<svg class="js-dropdown-icon-private dropdown-custom-icon {{ dropdown_classes.icon }}">
			<use xlink:href="#chevron-down"/>
		</svg>
	</button>

	<div class="js-dropdown-options-private dropdown-custom-options {{ dropdown_classes.options_container }}" style="display:none;">
		{% if option_custom_content %}
			{{ option_custom_content | raw }}
		{% else %}
			{% for option in options %}
				{% if option_property is defined %}
					{% set formatted_option = attribute(option, option_property) %}
				{% else %}
					{% set formatted_option = option.name is defined ? option.name : option %}
				{% endif %}

				<div class="js-dropdown-option-private dropdown-custom-option {{ dropdown_classes.option }} {% if (select_first and loop.first) or (custom_default_value and option.id is same as(custom_default_value)) %}selected{% endif %}" data-dropdown-option-text="{{ formatted_option }}" data-dropdown-option-value="{{ option.id }}">
					{{ formatted_option }}
				</div>
			{% endfor %}
		{% endif %}
	</div>
</div>
