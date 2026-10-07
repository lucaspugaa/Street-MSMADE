{#
	Progress Bar
	Shared bar skeleton for gift and free-shipping progress bars.
#}
{% set initial_percentage = initial_percentage ?? 0 %}
{% set is_visible = visibility_condition is not defined or visibility_condition %}
<div class="progress-bar {{ container_class }}" {% if not is_visible %}style="display: none;"{% endif %}>
	<div class="progress-bar-header">
		<div class="progress-bar-title {{ title_class }}">
			{%- block title_content %}{% endblock -%}
		</div>
		{% if icon_name %}
			{% include "snippets/icon.tpl" with { name: icon_name, class: 'progress-bar-icon' } %}
		{% endif %}
	</div>
	<div class="progress-bar-subtitle">
		{%- block subtitle_content %}{% endblock -%}
	</div>
	<div class="js-bar-progress bar-progress">
		<div class="js-bar-progress-active bar-progress-active" style="width: {{ initial_percentage }}%;"></div>
	</div>
</div>
