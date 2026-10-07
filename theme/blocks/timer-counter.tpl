{# Timer Counter Block - Countdown cards (hours, minutes, seconds) #}

{% set counter_bg = block.settings.background_color | default('#000000') %}
{% set counter_text = block.settings.text_color | default('#FFFFFF') %}

{% set card_style = '' %}
{% if counter_bg %}
	{% set card_style = card_style ~ 'background: ' ~ counter_bg ~ '; ' %}
{% endif %}
{% if counter_text %}
	{% set card_style = card_style ~ 'color: ' ~ counter_text ~ ';' %}
{% endif %}

{% set card_title_classes = 'timer-offer-number' %}
{% set card_text_classes = 'timer-offer-text' %}

<div class="timer-offers-cards" {{ block | block_attributes }}>
	<div class="card"{% if card_style %} style="{{ card_style }}"{% endif %}>
		<div class="{% if not placeholder_countdown %}js-hours{% endif %} {{ card_title_classes }}">00</div>
		<div class="{{ card_text_classes }}">{{ 'dates.hours' | t }}</div>
	</div>
	<div class="card"{% if card_style %} style="{{ card_style }}"{% endif %}>
		<div class="{% if not placeholder_countdown %}js-minutes{% endif %} {{ card_title_classes }}">00</div>
		<div class="{{ card_text_classes }}">{{ 'dates.minutes' | t }}</div>
	</div>
	<div class="card"{% if card_style %} style="{{ card_style }}"{% endif %}>
		<div class="{% if not placeholder_countdown %}js-seconds{% endif %} {{ card_title_classes }}">00</div>
		<div class="{{ card_text_classes }}">{{ 'dates.seconds' | t }}</div>
	</div>
</div>

{% schema %}
{
  "name": "t:names.timer_counter",
  "icon": "ClockIcon",
  "deletable": false,
  "limit": 1,
  "settings": [
    {
      "type": "header",
      "content": "t:names.colors"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "background_color",
      "label": "t:settings.background",
      "default": "#000000",
      "default_setting": "text_color"
    },
    {
      "type": "setting",
      "setting_type": "color",
      "id": "text_color",
      "label": "t:settings.text",
      "default": "#FFFFFF",
      "default_setting": "background_color"
    }
  ]
}
{% endschema %}
