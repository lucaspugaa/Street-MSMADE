{# FAQ Group Block - Container for FAQ list and image (50/50 layout on desktop) #}

{% set gap = block.settings.gap %}

<div
	class="faq-group flex-split-md w-100"
	{{ block | block_attributes }}
	data-store="faq-group-{{ block.id }}"
	style="gap: {{ gap }}px;"
>
	{% for child_block in block.blocks %}
		{% if child_block and child_block.type is defined %}
			{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
		{% endif %}
	{% endfor %}
</div>

{% schema %}
{
  "name": "t:names.faq_group",
  "icon": "FolderIcon",
  "deletable": false,
  "limit": 1,
  "blocks": [
    { "type": "faq-list", "limit": 1 },
    { "type": "image", "limit": 1 }
  ],
  "settings": [
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
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 0,
      "icon": "horizontal_spacing"
    }
  ]
}
{% endschema %}
