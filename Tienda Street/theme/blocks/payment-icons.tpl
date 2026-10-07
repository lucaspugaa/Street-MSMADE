{#
  Payment Icons Block
  Displays store payment method logos in a horizontal list.
#}

{%- set payment_settings = block.settings -%}

<div class="block-payment-icons" {{ block | block_attributes }}>
  {% if payment_settings.title %}
    <h4 class="block-payment-icons-title">{{ payment_settings.title }}</h4>
  {% endif %}

  {% if store.payment_methods %}
    <ul class="block-payment-icons-list">
      {% for payment in store.payment_methods %}
        <li class="block-payment-icons-item">
          {% include 'snippets/image.tpl' with {
            image_src: payment.logo,
            image_alt: payment.name,
            image_lazy_js: true,
            image_classes: 'block-payment-icons-icon fade-in',
            image_thumbs: false,
          } %}
        </li>
      {% endfor %}
    </ul>
  {% endif %}
</div>

{% schema %}
{
  "name": "t:names.payment_icons",
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "title",
      "label": "t:settings.title"
    },
    {
      "type": "paragraph",
      "content": "t:content.payment_icons_info"
    }
  ],
  "presets": [
    {
      "name": "t:names.payment_icons",
      "category": "t:categories.content"
    }
  ]
}
{% endschema %}
