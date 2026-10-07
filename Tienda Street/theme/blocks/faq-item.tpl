{# FAQ Item Block - Question and Answer #}

{%- set faq = block.settings -%}

<div class="js-accordion-private-container accordion-item" {{ block | block_attributes }}>
  <button class="js-accordion-private-toggle accordion-item-toggle accordion-item-header" type="button">
    <span class="accordion-item-toggle-text">{{ faq.question }}</span>
    <span class="accordion-item-toggle-icon">
      <svg class="js-accordion-private-toggle-active icon-inline"{% if faq.open_default %} style="display: none;"{% endif %}><use xlink:href="#chevron-down"/></svg>
      <svg class="js-accordion-private-toggle-inactive icon-inline"{% if not faq.open_default %} style="display: none;"{% endif %}><use xlink:href="#chevron-up"/></svg>
    </span>
  </button>
  <div class="js-accordion-private-content"{% if not faq.open_default %} style="display: none;"{% endif %}>
    <div class="accordion-item-body user-content">
      {{ faq.answer | raw }}
    </div>
  </div>
</div>

{% schema %}
{
  "name": "t:names.faq_item",
  "icon": "QuestionCircleIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "question",
      "label": "t:settings.question",
      "default": "t:defaults.faq_item.question"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "answer",
      "label": "t:settings.answer",
      "default": "t:defaults.faq_item.answer"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "open_default",
      "label": "t:settings.open_by_default",
      "default": false
    }
  ]
}
{% endschema %}
