{# Modal
 Modal dialog with header, body, optional footer, and overlay.
 Uses {% embed %} + {% block %} for content injection (body, footer).
 #}

{% set positions = ['top', 'right', 'left', 'bottom'] %}
{% set position_class = position.appear_from in positions ? position.appear_from : 'bottom' %}
{% set position_md_class = position.appear_desktop_from in positions ? position.appear_desktop_from : 'bottom' %}
{% set docked_md_position_class = position.dock_desktop == 'right' ? 'right' : position.dock_desktop == 'left' ? 'left' %}
{% set modal_md_position_classes = position.dock_desktop ? 'modal-md-docked modal-md-docked-' ~  docked_md_position_class : 'modal-md-' ~ position_md_class %}
{% set modal_close_all_classes = dismiss_all_modals_on_close ? 'js-modal-close-all-private' %}

{% set widths = ['full', 'large', 'small'] %}
{% set width_class = layout.width_mobile in widths ? layout.width_mobile : 'full' %}
{% set width_md_class = layout.width_desktop in widths ? layout.width_desktop : 'medium' %}

{% set overlay = layout.overlay ?? true %}

<div id="{{ modal_id }}" class="js-modal-private modal modal-{{ position_class }} {{ modal_md_position_classes }} modal-width-{{ width_class }} modal-md-width-{{ width_md_class }} {{ modal_classes.modal }}" style="display: none;" {% if data_component %}data-component="{{ data_component }}"{% endif %} {% if custom_data_attribute %}data-{{ custom_data_attribute }}="{{ custom_data_attribute_value }}"{% endif %} {% if data_attributes %}{% for key, value in data_attributes %}data-{{ key }}="{{ value | escape }}"{% endfor %}{% endif %} data-url="{{ modal_id }}">
	{% if form %}
		<form action="{{ form_action }}" method="post" class="modal-form {{ modal_classes.form }}" {% if form_data_store %}data-store="{{ form_data_store }}"{% endif %}>
	{% endif %}
			<div class="modal-header {{ modal_classes.header }}">
				{% if back_button %}
					<button class="js-modal-close-private modal-close modal-back {{ modal_classes.back_button }}" data-target="#{{ modal_id }}" data-modal-url="{{ modal_id }}">
						<svg class="icon-flip-horizontal modal-close-icon {{ modal_classes.close_icon }} {{ modal_classes.back_icon }}"><use xlink:href="#chevron"/></svg>
					</button>
				{% endif %}
				{% if title %}
					{% if back_button %}
						<button class="js-modal-close-private modal-title {{ modal_classes.title }}" data-target="#{{ modal_id }}" data-modal-url="{{ modal_id }}">
							{{ title }}
						</button>
					{% else %}
						<span class="modal-title {{ modal_classes.title }}">{{ title }}</span>
					{% endif %}
				{% endif %}
				<button class="js-modal-close-private {{ modal_close_all_classes }} modal-close {{ modal_classes.close_button }}" data-target="#{{ modal_id }}" data-modal-url="{{ modal_id }}">
					<svg class="modal-close-icon {{ modal_classes.close_icon }}"><use xlink:href="#times"/></svg>
				</button>
			</div>
			<div class="modal-body {{ modal_classes.body }}">
				{% block modal_body %}{% endblock %}
			</div>
			{% if modal_footer %}
				<div class="modal-footer {{ modal_classes.footer }}">
					{% block modal_foot %}{% endblock %}
				</div>
			{% endif %}
	{% if form %}
		</form>
	{% endif %}
</div>
{% if overlay %}
	<div class="js-modal-close-private js-modal-overlay-private modal-overlay {{ modal_classes.overlay }}" data-overlay-id="#{{ modal_id }}" data-target="#{{ modal_id }}" data-modal-url="{{ modal_id }}" style="display: none;"></div>
{% endif %}
