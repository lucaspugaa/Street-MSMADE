{# Mismo contenedor que renderizaba la sección custom con los defaults de su schema
   (section_width "page" → div.container, vertical_padding 64, fondo transparente). #}
<div
	class="section-custom "
	data-section-id="{{ section.id }}"
	style="padding-top: 64px; padding-bottom: 64px; background-color: transparent;">
<div class="container">
<div class="custom-section-content d-flex flex-column align-items-start justify-content-center" style="gap: 16px; text-align: left;">
<div class="code-block block-fill" data-store="code-block-home_portal">
<section class="parent-universes portal-home" aria-label="STREET 1640 · Portada y universos" data-home-layout="covers">
<div class="home-proposal-panel">
<div><strong>LANDING / TEST</strong><p class="home-proposal-label" aria-live="polite"></p></div>
<nav class="home-proposal-options" aria-label="Elegir estilo de landing"></nav>
</div>
<div class="portal-masthead">
<p>{{ section.settings.masthead_subtitle | escape }}</p>
<h1>{{ section.settings.masthead_title | escape }} <span>{{ section.settings.masthead_number | escape }}</span></h1>
<nav aria-label="Universos"><a href="{{ section.settings.nav_kumo | escape }}">KUMØ</a><a href="{{ section.settings.nav_futbol | escape }}">90</a><a href="{{ section.settings.nav_artistas | escape }}">ARTISTAS</a><a href="{{ section.settings.nav_f1 | escape }}">F1</a></nav>
</div>
<div class="portal-banners">
{% for block in section.blocks %}{% include 'blocks/home-universe-banner.tpl' with { block: block } %}
{% endfor %}
</div>
<div class="portal-bestsellers" aria-label="Más vendidos por universo"></div>
<div class="portal-trust-host"></div>
</section>
</div>
{# Both empty flex children preserve the original two 16px gaps. They are not editor blocks. #}
<div class="code-block block-fill" data-store="code-block-landing_page" data-module="LandingPage" data-countdown-target="{{ section.settings.countdown_target | escape }}" data-countdown-label="{{ section.settings.countdown_label | escape }}"></div>
<div class="code-block block-fill" data-store="code-block-home_layouts"></div>
</div>
</div>
</div>

{% schema %}
{
  "name": "Home · Street 1640",
  "icon": "LayoutIcon",
  "class": "section section-custom-container",
  "blocks": [
    {
      "type": "home-universe-banner"
    }
  ],
  "settings": [
    {
      "type": "setting",
      "setting_type": "text",
      "id": "masthead_subtitle",
      "label": "Bajada de la portada",
      "default": "INDUMENTARIA / MARTÍNEZ, BUENOS AIRES"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "masthead_title",
      "label": "Título de la portada",
      "default": "STREET"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "masthead_number",
      "label": "Número de la portada",
      "default": "1640"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "nav_kumo",
      "label": "Enlace KUMØ",
      "default": "#kumo-preview"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "nav_futbol",
      "label": "Enlace Fútbol",
      "default": "#football-preview"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "nav_artistas",
      "label": "Enlace Artistas",
      "default": "#artistas-preview"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "nav_f1",
      "label": "Enlace F1",
      "default": "#f1-preview"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "countdown_target",
      "label": "Fecha y hora objetivo (ISO 8601 con zona horaria)",
      "default": "2026-10-21T00:00:00-03:00"
    },
    {
      "type": "setting",
      "setting_type": "text",
      "id": "countdown_label",
      "label": "Texto de la cuenta regresiva",
      "default": "21 OCT 2026 / ARGENTINA · CUENTA HASTA EL DÍA DEL SHOW"
    }
  ],
  "presets": [
    {
      "name": "Home · Street 1640",
      "settings": {
        "masthead_subtitle": "INDUMENTARIA / MARTÍNEZ, BUENOS AIRES",
        "masthead_title": "STREET",
        "masthead_number": "1640",
        "nav_kumo": "#kumo-preview",
        "nav_futbol": "#football-preview",
        "nav_artistas": "#artistas-preview",
        "nav_f1": "#f1-preview",
        "countdown_target": "2026-10-21T00:00:00-03:00",
        "countdown_label": "21 OCT 2026 / ARGENTINA · CUENTA HASTA EL DÍA DEL SHOW"
      },
      "blocks": [
        {
          "type": "home-universe-banner",
          "settings": {
            "variant": "bts",
            "link": "#artistas-preview",
            "aria_label": "Entrar a BTS ARIRANG",
            "eyebrow": "BTS / WORLD TOUR",
            "title": "ARIRANG",
            "description": "ARGENTINA / 21.10.2026",
            "enter": "VER BTS ↗",
            "image_url": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-artistas-frente-b1171d1da2ff30342f17874347053002-480-0.webp",
            "image_2_url": "https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-2-0-negrodorso-9cc59272b32d0b8aac17874366236354-480-0.webp",
            "image_srcset": "",
            "art_text": "ARTISTAS",
            "art_text_2": "BTS",
            "art_text_3": "ARG",
            "index": "01"
          }
        },
        {
          "type": "home-universe-banner",
          "settings": {
            "variant": "kumo",
            "link": "#kumo-preview",
            "aria_label": "Entrar a KUMØ · comparar tres propuestas",
            "eyebrow": "ANIME / 雲",
            "title": "KUMØ",
            "description": "",
            "enter": "VER KUMØ ↗",
            "image_url": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp",
            "image_2_url": "",
            "image_srcset": "https://acdn-us.mitiendanube.com/stores/004/626/860/media/d9af73a8-kumo-480/source.webp 480w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/f31f98f0-kumo-960/source.webp 960w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp 1672w",
            "art_text": "ARTISTAS",
            "art_text_2": "BTS",
            "art_text_3": "ARG",
            "index": "02"
          }
        },
        {
          "type": "home-universe-banner",
          "settings": {
            "variant": "futbol",
            "link": "#football-preview",
            "aria_label": "Entrar a 90 — comparar cinco propuestas",
            "eyebrow": "FÚTBOL / ARCHIVO 90 MINUTOS",
            "title": "90",
            "description": "SELECCIÓN ARGENTINA / ÍDOLOS",
            "enter": "VER FÚTBOL ↗",
            "image_url": "",
            "image_2_url": "",
            "image_srcset": "",
            "art_text": "90",
            "art_text_2": "FÚTBOL",
            "art_text_3": "ARG",
            "index": "03"
          }
        },
        {
          "type": "home-universe-banner",
          "settings": {
            "variant": "artistas",
            "link": "#artistas-preview",
            "aria_label": "Entrar a ARTISTAS — comparar cinco propuestas",
            "eyebrow": "ARTISTAS / BTS",
            "title": "ARTISTAS",
            "description": "OASIS / AIRBAG\nBAD BUNNY / DUKI / TRUENO\nLANZAMIENTO / BTS",
            "enter": "VER ARTISTAS ↗",
            "image_url": "",
            "image_2_url": "",
            "image_srcset": "",
            "art_text": "ARTISTAS",
            "art_text_2": "BTS",
            "art_text_3": "ARG",
            "index": "04"
          }
        },
        {
          "type": "home-universe-banner",
          "settings": {
            "variant": "f1",
            "link": "#f1-preview",
            "aria_label": "Entrar a F1 — comparar cinco propuestas",
            "eyebrow": "MOTORSPORT",
            "title": "F1",
            "description": "COLAPINTO / FERRARI / MCLAREN",
            "enter": "VER F1 ↗",
            "image_url": "",
            "image_2_url": "",
            "image_srcset": "",
            "art_text": "ARTISTAS",
            "art_text_2": "BTS",
            "art_text_3": "ARG",
            "index": "05"
          }
        }
      ]
    }
  ]
}
{% endschema %}
