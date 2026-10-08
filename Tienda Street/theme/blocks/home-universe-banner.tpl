{# image_picker uses @media-lib references; text URLs preserve the original CDN assets. -#}
{% set image_1 = block.settings.image | default(block.settings.image_url) -%}
{% set image_2 = block.settings.image_2 | default(block.settings.image_2_url) -%}
{% if image_1 starts with '@media-lib:' -%}{% set image_1 = (image_1 | resolve_media).sourceUrl -%}{% endif -%}
{% if image_2 starts with '@media-lib:' -%}{% set image_2 = (image_2 | resolve_media).sourceUrl -%}{% endif -%}
{% set banner = block.settings -%}
{% if banner.variant == 'bts' -%}
<a class="portal-banner portal-bts" {{ block | block_attributes }} href="{{ banner.link | escape }}" aria-label="{{ banner.aria_label | escape }}">
<div class="portal-banner-copy"><span class="portal-eyebrow">{{ banner.eyebrow | escape }}</span><h2>{{ banner.title | escape }}</h2>{% if banner.description %}<p>{{ banner.description | escape | replace(' | ', '<br>') | raw }}</p>{% endif %}<span class="portal-enter">{{ banner.enter | escape }}</span></div>
<div class="portal-bts-art" aria-hidden="true"><img src="{{ image_1 | escape }}" alt="" width="480" height="600" fetchpriority="high"><img src="{{ image_2 | escape }}" alt="" width="480" height="600" fetchpriority="high"></div>
<div class="portal-countdown" aria-label="Cuenta hasta el día del primer show"></div>
<span class="portal-index" aria-hidden="true">{{ banner.index | escape }}</span>
</a>
{% elseif banner.variant == 'kumo' -%}
<a class="portal-banner portal-kumo card-kumo" {{ block | block_attributes }} href="{{ banner.link | escape }}" aria-label="{{ banner.aria_label | escape }}">
<div class="portal-banner-copy"><span class="portal-eyebrow">{{ banner.eyebrow | escape }}</span><h2>{{ banner.title | escape }}</h2>{% if banner.description %}<p>{{ banner.description | escape | replace(' | ', '<br>') | raw }}</p>{% endif %}<span class="portal-enter">{{ banner.enter | escape }}</span></div>
<img class="portal-kumo-art" src="{{ image_1 | escape }}"{% if not banner.image and banner.image_srcset %} srcset="{{ banner.image_srcset | escape }}"{% endif %} sizes="(max-width: 600px) 60vw, 30vw" alt="" width="1920" height="960" loading="lazy" decoding="async">
<span class="portal-index" aria-hidden="true">{{ banner.index | escape }}</span>
</a>
{% elseif banner.variant == 'futbol' -%}
<a class="portal-banner portal-football card-futbol" {{ block | block_attributes }} href="{{ banner.link | escape }}" aria-label="{{ banner.aria_label | escape }}">
<div class="portal-banner-copy"><span class="portal-eyebrow">{{ banner.eyebrow | escape }}</span><h2>{{ banner.title | escape }}</h2>{% if banner.description %}<p>{{ banner.description | escape | replace(' | ', '<br>') | raw }}</p>{% endif %}<span class="portal-enter">{{ banner.enter | escape }}</span></div>
<div class="portal-football-art" aria-hidden="true"><span>{{ banner.art_text | escape }}</span><i>{{ banner.art_text_2 | escape }}</i><b>{{ banner.art_text_3 | escape }}</b></div>
<span class="portal-index" aria-hidden="true">{{ banner.index | escape }}</span>
</a>
{% elseif banner.variant == 'artistas' -%}
<a class="portal-banner portal-artists card-artistas" {{ block | block_attributes }} href="{{ banner.link | escape }}" aria-label="{{ banner.aria_label | escape }}">
<div class="portal-banner-copy"><span class="portal-eyebrow">{{ banner.eyebrow | escape }}</span><h2>{{ banner.title | escape }}</h2>{% if banner.description %}<p>{{ banner.description | escape | replace(' | ', '<br>') | raw }}</p>{% endif %}<span class="portal-enter">{{ banner.enter | escape }}</span></div>
<div class="portal-record-art" aria-hidden="true"><span>{{ banner.art_text | escape }}</span><span>{{ banner.art_text_2 | escape }}</span></div>
<span class="portal-index" aria-hidden="true">{{ banner.index | escape }}</span>
</a>
{% elseif banner.variant == 'f1' -%}
<a class="portal-banner portal-f1" {{ block | block_attributes }} href="{{ banner.link | escape }}" aria-label="{{ banner.aria_label | escape }}">
<div class="portal-banner-copy"><span class="portal-eyebrow">{{ banner.eyebrow | escape }}</span><h2>{{ banner.title | escape }}</h2>{% if banner.description %}<p>{{ banner.description | escape | replace(' | ', '<br>') | raw }}</p>{% endif %}<span class="portal-enter">{{ banner.enter | escape }}</span></div><span class="portal-index" aria-hidden="true">{{ banner.index | escape }}</span>
</a>
{%- endif -%}
{% schema %}
{
  "name": "Banner de universo",
  "settings": [
    {
      "type": "setting",
      "setting_type": "select",
      "id": "variant",
      "label": "Universo",
      "default": "bts",
      "options": [
        {
          "value": "bts",
          "label": "BTS"
        },
        {
          "value": "kumo",
          "label": "KUMØ"
        },
        {
          "value": "futbol",
          "label": "Fútbol"
        },
        {
          "value": "artistas",
          "label": "Artistas"
        },
        {
          "value": "f1",
          "label": "F1"
        }
      ]
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "link",
      "label": "Enlace del banner",
      "default": "#artistas-preview"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "aria_label",
      "label": "Descripción accesible",
      "default": "Entrar a BTS ARIRANG"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "eyebrow",
      "label": "Bajada",
      "default": "BTS / WORLD TOUR"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "title",
      "label": "Título",
      "default": "ARIRANG"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "description",
      "label": "Descripción (separá renglones con |)",
      "default": "ARGENTINA / 21.10.2026"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "enter",
      "label": "Texto del enlace",
      "default": "VER BTS ↗"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "image_url",
      "label": "URL de imagen",
      "default": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-artistas-frente-b1171d1da2ff30342f17874347053002-480-0.webp",
      "visible_if": "{{ block.settings.variant == 'bts' or block.settings.variant == 'kumo' }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "image_2_url",
      "label": "URL de segunda imagen (BTS)",
      "default": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-2-0-negrodorso-9cc59272b32d0b8aac17874366236354-480-0.webp",
      "visible_if": "{{ block.settings.variant == 'bts' }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "image_srcset",
      "label": "Imágenes responsivas (URL y ancho, KUMØ)",
      "default": "",
      "visible_if": "{{ block.settings.variant == 'kumo' and not block.settings.image }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "art_text",
      "label": "Texto del arte",
      "default": "ARTISTAS",
      "visible_if": "{{ block.settings.variant == 'futbol' or block.settings.variant == 'artistas' }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "art_text_2",
      "label": "Segundo texto del arte",
      "default": "BTS",
      "visible_if": "{{ block.settings.variant == 'futbol' or block.settings.variant == 'artistas' }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "art_text_3",
      "label": "Tercer texto del arte (fútbol)",
      "default": "ARG",
      "visible_if": "{{ block.settings.variant == 'futbol' }}"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "index",
      "label": "Número del banner",
      "default": "01"
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image",
      "label": "Reemplazar imagen (opcional)",
      "visible_if": "{{ block.settings.variant == 'bts' or block.settings.variant == 'kumo' }}"
    },
    {
      "type": "setting",
      "setting_type": "image_picker",
      "id": "image_2",
      "label": "Reemplazar segunda imagen (BTS, opcional)",
      "visible_if": "{{ block.settings.variant == 'bts' }}"
    }
  ]
}
{% endschema %}
