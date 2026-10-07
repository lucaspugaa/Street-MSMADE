{#
  Accordion Block
  Expandable item with title and content, optionally with an icon.
#}

{%- set accordion_settings = block.settings -%}

<div class="block-accordion" {{ block | block_attributes }}>
  <details class="accordion-item" {% if accordion_settings.open_default %}open{% endif %}>
    <summary class="accordion-item-header">
      {% if accordion_settings.icon %}
        <span class="accordion-item-icon">
          {% include 'snippets/icon.tpl' with { name: accordion_settings.icon, size: 20 } %}
        </span>
      {% endif %}
      <span class="accordion-item-title">{{ accordion_settings.title }}</span>
      <span class="accordion-item-toggle">
        {% include 'snippets/icon.tpl' with { name: 'chevron-down', size: 16 } %}
      </span>
    </summary>
    <div class="accordion-item-content user-content">
      {{ accordion_settings.content | raw }}
    </div>
  </details>
</div>

{% schema %}
{
  "name": "t:names.accordion",
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "title",
      "label": "t:settings.title",
      "default": "t:defaults.accordion.title"
    },
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "content",
      "label": "t:settings.content",
      "default": "t:defaults.accordion.content"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "open_default",
      "label": "t:settings.open_by_default",
      "default": false
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "icon",
      "label": "t:settings.icon",
      "options": [
        { "value": "", "label": "t:options.none" },
        { "value": "shipping", "label": "t:options.shipping" },
        { "value": "returns", "label": "t:options.returns" },
        { "value": "security", "label": "t:options.security" },
        { "value": "info", "label": "t:options.info" },
        { "value": "question", "label": "t:options.question" }
      ],
      "default": ""
    }
  ],
  "presets": [
    {
      "name": "t:names.accordion",
      "category": "t:categories.content",
      "settings": {
        "title": "t:defaults.accordion.title",
        "content": "t:defaults.accordion.content"
      }
    }
  ]
}
{% endschema %}
