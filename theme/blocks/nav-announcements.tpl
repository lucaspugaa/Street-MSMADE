{# Nav Announcements Block — group of announcement sub-blocks for the navigation bar #}

{% set alignment = block.settings.alignment | default('center') %}
{% set justify_class = alignment == 'center' ? 'justify-content-center' : (alignment == 'right' ? 'justify-content-end' : 'justify-content-start') %}
{% set block_gap = block.settings.gap | default(16) %}
{% set is_mobile_menu = type == 'mobile_menu' %}

{% if is_mobile_menu %}
	<ul class="list-unstyled">
		{% for child_block in block.blocks %}
			{% if child_block and child_block.type == 'announcement' %}
				{% include 'blocks/announcement.tpl' with { block: child_block, type: 'mobile_menu' } %}
			{% endif %}
		{% endfor %}
	</ul>
{% else %}
	<div class="navigation-bar-block {{ justify_class }}" style="gap: {{ block_gap }}px" {{ block | block_attributes }}>
		{% for child_block in block.blocks %}
			{% if child_block and child_block.type == 'announcement' %}
				{% include 'blocks/announcement.tpl' with { block: child_block } %}
			{% endif %}
		{% endfor %}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.navbar_announcements",
  "icon": "MarketingIcon",
  "blocks": [
    { "type": "announcement", "limit": 4 }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "alignment",
      "label": "t:settings.desktop_alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "center"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 120,
      "step": 2,
      "unit": "px",
      "default": 16,
      "icon": "horizontal_spacing"
    }
  ],
  "presets": [
    {
      "name": "t:names.navbar_announcements",
      "settings": { "alignment": "center", "gap": 16 },
      "blocks": [
        {
          "type": "announcement",
          "settings": { "text": "t:defaults.announcements.announcement_1" }
        },
        {
          "type": "announcement",
          "settings": { "text": "t:defaults.announcements.announcement_2" }
        }
      ]
    }
  ]
}
{% endschema %}
