{# Promotional Modal - Configured from global settings (promotional_popup_*) #}

{% set has_desktop_image = settings.promotional_popup_image %}
{% set has_mobile_image = settings.promotional_popup_use_mobile_image and settings.promotional_popup_image_mobile %}
{% set has_image = has_desktop_image or has_mobile_image %}
{% set is_responsive_image = has_desktop_image and has_mobile_image %}

{% set image_right = settings.promotional_popup_image_position == 'right' %}
{% set alignment = settings.promotional_popup_alignment | default('left') %}
{% set is_newsletter = settings.promotional_popup_newsletter %}

{% set title_style = settings.promotional_popup_title_style | default('h4') %}
{% set title_style_mobile = settings.promotional_popup_title_mobile_style ? (settings.promotional_popup_title_style_mobile | default('h3')) : title_style %}

{% set description_style = settings.promotional_popup_description_style | default('paragraph') %}
{% set description_size_class = description_style == 'paragraph_small' ? 'font-small' : (description_style == 'paragraph_big' ? 'font-big' : '') %}

{% set btn_align = alignment == 'center' ? 'center' : (alignment == 'right' ? 'end' : 'start') %}

{% set newsletter_success = contact and contact.type == 'newsletter' and contact.success %}
{% set modal_width = has_image ? 'large' : 'small' %}

{% set image_alt = settings.promotional_popup_image | media_alt | default('accessibility.promotional_popup' | t) %}
{% set image_mobile_alt = settings.promotional_popup_image_mobile | media_alt | default('accessibility.promotional_popup' | t) %}

{% embed 'snippets/modals/modal.tpl' with {
	modal_id: 'promotional-modal',
	position: {
		appear_from: 'bottom',
		appear_desktop_from: 'bottom',
	},
	layout: {
		width_mobile: 'small',
		width_desktop: modal_width,
	},
	modal_classes: {
		header: 'modal-header-close-only',
		close_icon: 'icon-inline',
	},
	data_attributes: {
		'newsletter-success': newsletter_success ? 'true' : 'false',
		'contact-url': store.contact_url,
	},
} %}

	{% block modal_body %}
		{% if has_image %}
			<div class="media-grid media-grid-md-horizontal media-grid-align-start {% if image_right %}media-grid-content-left{% endif %}">
				<div class="media-visual">
					{% if has_desktop_image %}
						{% include 'snippets/image.tpl' with {
							image_src: settings.promotional_popup_image,
							image_alt: image_alt,
							image_classes: 'img-fluid' ~(is_responsive_image ? ' d-none d-md-block' : ''),
							image_lazy_js: true,
						} %}
					{% endif %}
					{% if has_mobile_image %}
						{% include 'snippets/image.tpl' with {
							image_src: settings.promotional_popup_image_mobile,
							image_alt: image_mobile_alt,
							image_classes: 'img-fluid' ~(is_responsive_image ? ' d-md-none' : ''),
							image_lazy_js: true,
						} %}
					{% endif %}
					{% if settings.promotional_popup_url %}
						<a href="{{ settings.promotional_popup_url }}" class="promotional-modal-image-link" aria-label="{{ settings.promotional_popup_title | striptags }}"></a>
					{% endif %}
				</div>
		{% endif %}
				<div class="promotional-modal-content text-{{ alignment }}">
					{% if settings.promotional_popup_title %}
						<div class="{{ title_style_mobile != title_style ? title_style ~ '-md ' ~ title_style_mobile : title_style }} promotional-modal-title">
							{{ settings.promotional_popup_title | raw }}
						</div>
					{% endif %}
					{% if settings.promotional_popup_description %}
						<div class="promotional-modal-description {{ description_size_class }}">
							{{ settings.promotional_popup_description | raw }}
						</div>
					{% endif %}
					{% if is_newsletter %}
						<div class="js-newsletter-form-wrapper">
							{% include 'snippets/forms/newsletter.tpl' with {
								form_data_store: 'promotional-modal-newsletter',
								ajax_submit: true,
								submit_label: settings.promotional_popup_button_text,
								submit_classes: 'newsletter-form-button btn btn-inline btn-primary',
							} %}
						</div>
					{% elseif settings.promotional_popup_button_text %}
						<a href="{{ settings.promotional_popup_button_link }}" class="btn btn-primary align-self-{{ btn_align }}">{{ settings.promotional_popup_button_text }}</a>
					{% endif %}
				</div>
		{% if has_image %}
			</div>
		{% endif %}
	{% endblock %}
{% endembed %}
