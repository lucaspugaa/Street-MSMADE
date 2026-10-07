{# Icon snippet - Renders SVG icons from the theme sprite #}
{# When size is not passed, dimensions are controlled by CSS (no inline styles) #}
{%- set icon_size = size | default(24) -%}
{%- set icon_class = class | default('') -%}

{# Map icon names to sprite IDs #}
{% set icon_id = name %}

{# Some icons have different IDs in the sprite #}
{% if name == 'shipping' %}
  {% set icon_id = 'truck' %}
{% elseif name == 'card' or name == 'credit_card' %}
  {% set icon_id = 'credit-card' %}
{% elseif name == 'spinner' %}
  {% set icon_id = 'spinner-third' %}
{% endif %}

<svg class="{% if icon_class %}{{ icon_class }}{% endif %} icon-inline"{% if size is defined and size is not none %} style="width: {{ icon_size }}px; height: {{ icon_size }}px;"{% endif %}>
  <use xlink:href="#{{ icon_id }}"/>
</svg>
