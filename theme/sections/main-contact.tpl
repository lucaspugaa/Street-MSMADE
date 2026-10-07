{#
  Contact Section
  Contact form with optional store contact info (phone, email, address, etc.).
#}
{% set has_contact_info = store.whatsapp or store.phone or store.email or store.address or store.blog or store.contact_intro %}
{% set is_order_cancellation_without_id = params.order_cancellation_without_id == 'true' %}

{# Layout settings #}
{% set page_width = section.settings.section_width | default('page') == 'page' %}
{% set vertical_padding = section.settings.vertical_padding | default(0) %}
{% set horizontal_padding = page_width ? 0 : section.settings.horizontal_padding %}


<div
  class="contact-form-section"
  data-store="contact-form"
  style="padding: {{ vertical_padding }}px {{ horizontal_padding }}px;"
>
  {% if page_width %}
    <div class="container">
  {% endif %}
    <div class="d-grid grid-md-2">

      {% if has_contact_info and not is_order_cancellation %}
        <div class="contact-info-container">
          {% if store.contact_intro %}
            <p class="contact-intro">{{ store.contact_intro }}</p>
          {% endif %}
          <ul class="list list-unstyled">
            {% set list_classes = 'contact-info-item' %}
            {% set list_with_icons_classes = 'd-flex align-items-center' %}
            {% set icon_classes = 'contact-info-icon icon-inline' %}
            {% if store.whatsapp %}
              <li class="{{ list_classes }} {{ list_with_icons_classes }}">
                <a href="{{ store.whatsapp }}">
                  <svg class="{{ icon_classes }}"><use xlink:href="#whatsapp"/></svg>
                  {{ store.whatsapp | trim('https://wa.me/') }}
                </a>
              </li>
            {% endif %}
            {% if store.phone %}
              <li class="{{ list_classes }} {{ list_with_icons_classes }}">
                <a href="tel:{{ store.phone }}">
                  <svg class="{{ icon_classes }}"><use xlink:href="#phone"/></svg>
                  {{ store.phone }}
                </a>
              </li>
            {% endif %}
            {% if store.email %}
              <li class="{{ list_classes }} {{ list_with_icons_classes }}">
                <a href="mailto:{{ store.email }}">
                  <svg class="{{ icon_classes }}"><use xlink:href="#email"/></svg>
                  {{ store.email }}
                </a>
              </li>
            {% endif %}
            {% if store.address and not is_order_cancellation %}
              <li class="{{ list_classes }} {{ list_with_icons_classes }}">
                <svg class="{{ icon_classes }}"><use xlink:href="#location"/></svg>
                {{ store.address }}
              </li>
            {% endif %}
            {% if store.blog %}
              <li class="{{ list_classes }} {{ list_with_icons_classes }}">
                <a target="_blank" rel="noopener noreferrer" href="{{ store.blog }}">
                  <svg class="{{ icon_classes }}"><use xlink:href="#comments"/></svg>
                  {{ 'footer.visit_blog' | t }}
                </a>
              </li>
            {% endif %}
          </ul>
        </div>
      {% endif %}

      {% if is_order_cancellation %}
        <div class="contact-info-container">
          <div class="contact-cancellation-disclaimer">
            <p data-component="order-cancellation-disclaimer">{{ 'contact.cancellation_disclaimer' | t }}</p>
            <a class="btn-link" href="{{ status_page_url_regret }}"><strong>{{ 'contact.view_purchase_detail' | t }}</strong></a>
          </div>
          {% if has_contact_info %}
            <h5 class="contact-other-problems">{{ 'contact.other_purchase_problems' | t }}</h5>
            <div class="contact-divider divider"></div>
            {% if store.contact_intro %}
              <p class="contact-cancellation-intro">{{ store.contact_intro }}</p>
            {% endif %}
            {% include "snippets/social/contact-links.tpl" with {btn_link: true} %}
          {% endif %}
        </div>
      {% endif %}

      <div class="contact-form-container">
        {% if product %}
          <div class="contact-product-card">
            <div>
              {% include 'snippets/image.tpl' with {
                image_src: product.featured_image,
                product_image: true,
                image_lazy_js: true,
                image_classes: 'img-fluid fade-in',
                image_alt: product.name,
                image_thumbs: ['thumb', 'small'],
              } %}
            </div>
            <div class="contact-product-info">
              <p>{{ 'contact.consulting_product' | t }} </br> {{ product.name | a_tag(product.url) }}</p>
            </div>
          </div>
        {% endif %}

        {% if contact %}
          {% if contact.success %}
            {% if is_order_cancellation %}
              <div class="alert alert-success" data-component="order-cancellation-success-message">{{ 'contact.cancellation_sent' | t }} 
              <br>
              <p class="contact-success-followup">{{ 'contact.will_contact_you' | t }}</p>
              <br> 
              <strong>{{ 'contact.request_number' | t }} #{{ last_order_id }}</strong></div>
            {% else %}
              <div class="alert alert-success" data-component="contact-success-message">{{ 'contact.thanks' | t }}</div>
            {% endif %}
          {% else %}
            <div class="alert alert-danger">{{ 'contact.need_name_email' | t }}</div>
          {% endif %}
        {% endif %}

        {% if is_order_cancellation_without_id %}
          <p class="contact-disclaimer" data-component="order-cancellation-disclaimer">{{ 'contact.cancellation_disclaimer_with_order' | t | raw }}</p>
        {% endif %}

        {% embed "snippets/forms/form.tpl" with{form_id: 'contact-form', form_custom_class: 'js-winnie-pooh-form', form_action: '/winnie-pooh', submit_custom_class: 'btn-block', submit_name: 'contact', submit_text: 'general.send' | t, data_store: 'contact-form' } %}
          {% block form_body %}
            <div class="winnie-pooh hidden">
              <label for="winnie-pooh">{{ 'contact.do_not_fill' | t }}:</label>
              <input type="text" id="winnie-pooh" name="winnie-pooh">
            </div>
            <input type="hidden" value="{{ product.id }}" name="product"/>

            {% if is_order_cancellation or is_order_cancellation_without_id %}
              <input type="hidden" name="type" value="order_cancellation" />
            {% else %}
              <input type="hidden" name="type" value="contact" />
            {% endif %}

            {% embed "snippets/forms/form-input.tpl" with{input_for: 'name', type_text: true, input_name: 'name', input_id: 'name', input_label_text: 'contact.name' | t, input_placeholder: 'contact.name_placeholder' | t } %}
            {% endembed %}

            {% embed "snippets/forms/form-input.tpl" with{input_for: 'email', type_email: true, input_name: 'email', input_id: 'email', input_label_text: 'contact.email' | t, input_placeholder: 'contact.email_placeholder' | t } %}
            {% endembed %}

            {% if not is_order_cancellation %}
              {% embed "snippets/forms/form-input.tpl" with{input_for: 'phone', type_tel: true, input_name: 'phone', input_id: 'phone', input_label_text: 'contact.phone' | t, input_placeholder: 'contact.phone_placeholder' | t } %}
              {% endembed %}

              {% embed "snippets/forms/form-input.tpl" with{text_area: true, input_for: 'message', input_name: 'message', input_id: 'message', input_rows: '7', input_label_text: 'contact.message' | t, input_placeholder: 'contact.message_placeholder' | t } %}
              {% endembed %}
            {% endif %}
          {% endblock %}
        {% endembed %}
      </div>
    </div>
  {% if page_width %}
    </div>
  {% endif %}
</div>


{% schema %}
{
  "name": "t:names.contact_form",
  "class": "section section-main-contact",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.contact_form"}],
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "section_width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "page", "label": "t:options.page" },
        { "value": "full", "label": "t:options.full" }
      ],
      "default": "page"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "vertical_padding",
      "label": "t:settings.vertical_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 0,
      "icon": "vertical_padding"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "horizontal_padding",
      "label": "t:settings.horizontal_padding",
      "min": 0,
      "max": 120,
      "step": 4,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_padding",
      "disabled_if": "{{ section.settings.section_width == 'page' }}"
    }
  ],
  "enabled_on": {
    "page_templates": ["contact"]
  }
}
{% endschema %}
