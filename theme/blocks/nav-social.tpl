{# Nav Social Block — social media links for the navigation bar #}

{% set alignment = block.settings.alignment | default('right') %}
{% set justify_class = alignment == 'center' ? 'justify-content-center' : (alignment == 'right' ? 'justify-content-end' : 'justify-content-start') %}
{% set block_gap = block.settings.gap | default(16) %}
{% set is_mobile_menu = type == 'mobile_menu' %}

{% set has_social_network = store.facebook or store.twitter or store.pinterest or store.instagram or store.tiktok or store.youtube %}

{% if has_social_network %}
	{% if not is_mobile_menu %}
		<div class="navigation-bar-block {{ justify_class }}" {{ block | block_attributes }}>
	{% endif %}
			<div class="{{ not is_mobile_menu ? 'navigation-bar-social' : 'nav-secondary-social' }}" {% if not is_mobile_menu %}style="gap: {{ block_gap }}px"{% endif %}>
				{% for sn in ['instagram', 'facebook', 'youtube', 'tiktok', 'twitter', 'pinterest'] %}
					{% set sn_url = attribute(store, sn) %}
					{% if sn_url %}
						<a href="{{ sn_url }}" target="_blank" rel="noopener noreferrer" aria-label="{{ sn }} {{ store.name }}">
							<svg class="icon-inline"><use xlink:href="#{{ sn }}"/></svg>
						</a>
					{% endif %}
				{% endfor %}
			</div>
	{% if not is_mobile_menu %}
		</div>
	{% endif %}
{% endif %}

{% schema %}
{
  "name": "t:names.navbar_social",
  "icon": "ShareIcon",
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
      "default": "right"
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
      "name": "t:names.navbar_social",
      "settings": { "alignment": "right", "gap": 16 }
    }
  ]
}
{% endschema %}
