{# Category Navigation - Internal container for category items #}
{# Children are rendered by the section template #}

{% schema %}
{
  "name": "t:names.navigation",
  "icon": "folder",
  "blocks": [
    { "type": "category-item" }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "category_type",
      "label": "t:settings.category_type",
      "options": [
        { "value": "image_thumbnail", "label": "t:options.image_thumbnail" },
        { "value": "text_pill", "label": "t:options.text_pill" }
      ],
      "default": "image_thumbnail"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "format_text",
      "label": "t:settings.format",
      "options": [
        { "value": "rounded", "label": "t:options.rounded" },
        { "value": "square", "label": "t:options.square" }
      ],
      "default": "rounded",
      "visible_if": "{{ block.settings.category_type == 'text_pill' }}"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "format_image",
      "label": "t:settings.format",
      "options": [
        { "value": "circular", "label": "t:options.circle" },
        { "value": "square", "label": "t:options.square" }
      ],
      "default": "square",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' }}"
    },
    {
      "type": "header",
      "content": "t:names.disposition",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' }}"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "image_position",
      "label": "t:settings.image_position",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "top", "label": "t:options.top" }
      ],
      "default": "left",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "image_size",
      "label": "t:settings.image_size",
      "min": 40,
      "max": 300,
      "step": 4,
      "unit": "px",
      "default": 80,
      "icon": "SizeWidthIcon",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "horizontal_spacing"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "items_text_alignment",
      "label": "t:settings.items_text_alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" }
      ],
      "default": "left",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' and block.settings.image_position == 'top' }}"
    },
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "background_color",
      "label": "t:settings.background",
      "default": "transparent",
      "visible_if": "{{ block.settings.category_type == 'text_pill' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text_color",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "border_color",
      "label": "t:settings.border_color",
      "default_setting": "text_color",
      "visible_if": "{{ block.settings.category_type == 'text_pill' }}"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "image_border_color",
      "label": "t:settings.image_border_color",
      "default_setting": "text_color",
      "visible_if": "{{ block.settings.category_type == 'image_thumbnail' }}"
    }
  ]
}
{% endschema %}
