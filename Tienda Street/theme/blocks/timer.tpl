{# Timer Block - Countdown container with background image support #}

{% set timer_image = block.settings.image | default('images/placeholders/timer/timer-placeholder.webp' | static_url) %}
{% set background_color = block.settings.background_color | default('#FFFFFF') %}
{% set text_color = block.settings.text_color | default('#000000') %}

{% set horizontal_align = block.settings.alignment | default('center') %}
{% set vertical_align = block.settings.alignment_vertical | default('center') %}

{% set align_class = 'align-items-' ~ horizontal_align ~ ' justify-content-' ~ (vertical_align == 'top' ? 'start' : (vertical_align == 'bottom' ? 'end' : 'center')) %}

{% set block_gap = block.settings.gap | default(16) %}
{% set vertical_padding = block.settings.vertical_padding | default(60) %}
{% set horizontal_padding = block.settings.horizontal_padding | default(32) %}

{% set timer_styles = '' %}
{% if background_color %}
	{% set timer_styles = timer_styles ~ 'background-color: ' ~ background_color ~ '; ' %}
{% endif %}
{% if text_color %}
	{% set timer_styles = timer_styles ~ 'color: ' ~ text_color ~ ';' %}
{% endif %}

{% set image_alt = block.settings.image | media_alt | default('accessibility.timer' | t) %}

<div
	class="timer-block d-flex flex-column {{ align_class }} position-relative"
	{{ block | block_attributes }}
	data-store="timer-{{ block.id }}"
	{% if timer_styles %} style="{{ timer_styles }}"{% endif %}
>
	<div class="media-visual position-absolute">
		{% include 'snippets/image.tpl' with {
			image_src: timer_image,
			image_alt: image_alt,
			image_lazy_js: true,
			image_classes: 'timer-offers-image fade-in',
		} %}
	</div>

	<div class="timer-offers-content d-flex flex-column {{ align_class }} position-relative" style="gap: {{ block_gap }}px; padding: {{ vertical_padding }}px {{ horizontal_padding }}px;">
		{% for child_block in block.blocks %}
			{% if child_block and child_block.type is defined %}
				{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block } %}
			{% endif %}
		{% endfor %}
	</div>
</div>

{% schema %}
{
  "name": "t:names.timer",
  "icon": "FolderIcon",
  "deletable": false,
  "limit": 1,
  "blocks": [
    { "type": "heading" },
    { "type": "text" },
    {
      "type": "timer-counter",
      "deletable": false,
      "limit": 1
    },
    { "type": "button" },
    { "type": "group" },
    { "type": "image" }
  ],
  "settings": [
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "t:settings.background_image"
    },
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "start", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "end", "label": "t:options.right" }
      ],
      "default": "center",
      "vertical_options": [
        { "value": "top", "label": "t:options.top" },
        { "value": "center", "label": "t:options.center" },
        { "value": "bottom", "label": "t:options.bottom" }
      ],
      "vertical_default": "center"
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
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "vertical_spacing"
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
      "default": 60,
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
      "icon": "horizontal_padding"
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
      "default": "#FFFFFF",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default": "#000000",
      "default_setting": "background_color"
    }
  ]
}
{% endschema %}
