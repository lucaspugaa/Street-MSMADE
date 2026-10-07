{# Header Mobile Navigation Block #}

{% embed 'snippets/modals/modal.tpl' with {
    modal_id: 'nav-hamburger',
    data_component: 'nav-hamburger',
    modal_footer: true,
    position: {
        appear_from: 'left',
    },
    modal_classes: {
        modal: 'modal-nav-hamburger modal-nav-main',
        header: 'no-title',
        close_icon: 'icon-inline',
    }
} %}
    {% block modal_body %}
        {% include 'snippets/navigation/navigation-panel.tpl' with {primary_links: true, nav_block: navigation_block} %}
    {% endblock %}
    {% block modal_foot %}
        {% include 'snippets/navigation/navigation-panel.tpl' %}
    {% endblock %}
{% endembed %}

{# Search modal - used when search type is icon on mobile #}
{% embed 'snippets/modals/modal.tpl' with {
	modal_id: 'modal-search',
	data_component: 'modal-search',
	title: 'search.placeholder' | t,
	position: {
		appear_from: 'left',
	},
	layout: {
		width_mobile: 'full',
	},
	modal_classes: {
		modal: 'modal-nav-search',
		close_icon: 'icon-inline',
		body: 'modal-nav-search-body',
	}
} %}
	{% block modal_body %}
		{% include 'snippets/header/search-form.tpl' %}
	{% endblock %}
{% endembed %}

{# Languages modal #}
{% if languages | length > 1 %}
	{% embed 'snippets/modals/modal.tpl' with {
		modal_id: 'modal-languages',
		data_component: 'modal-languages',
		layout: {
			width_mobile: 'small',
			width_desktop: 'small',
		},
		title: 'general.languages_currencies' | t,
		modal_classes: {
			close_icon: 'icon-inline',
		}
	} %}
		{% block modal_body %}
			{% include 'snippets/navigation/country-options.tpl' %}
		{% endblock %}
	{% endembed %}
{% endif %}
