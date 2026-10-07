{# MSMADE · Portada de la home: masthead STREET 1640 y banners de universos (BTS, KUMØ, 90, ARTISTAS, F1).
   HTML copiado tal cual del bloque de código original (home · code_4h5e); el módulo LandingPage lo completa
   (cuenta regresiva, más vendidos, confianza de compra). Estilos: src/styles/modules/home-portal.css #}

<div class="code-block block-fill" {{ block | block_attributes }} data-store="code-block-{{ block.id }}">
<section class="parent-universes portal-home" aria-label="STREET 1640 · Portada y universos" data-home-layout="covers">
<div class="home-proposal-panel">
<div><strong>LANDING / TEST</strong><p class="home-proposal-label" aria-live="polite"></p></div>
<nav class="home-proposal-options" aria-label="Elegir estilo de landing"></nav>
</div>
<div class="portal-masthead">
<p>INDUMENTARIA / MARTÍNEZ, BUENOS AIRES</p>
<h1>STREET <span>1640</span></h1>
<nav aria-label="Universos"><a href="#kumo-preview">KUMØ</a><a href="#football-preview">90</a><a href="#artistas-preview">ARTISTAS</a><a href="#f1-preview">F1</a></nav>
</div>
<div class="portal-banners">
<a class="portal-banner portal-bts" href="#artistas-preview" aria-label="Entrar a BTS ARIRANG">
<div class="portal-banner-copy"><span class="portal-eyebrow">BTS / WORLD TOUR</span><h2>ARIRANG</h2><p>ARGENTINA / 21.10.2026</p><span class="portal-enter">VER BTS ↗</span></div>
<div class="portal-bts-art" aria-hidden="true"><img src="https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-artistas-frente-b1171d1da2ff30342f17874347053002-480-0.webp" alt="" width="480" height="600" fetchpriority="high"><img src="https://acdn-us.mitiendanube.com/stores/004/626/860/products/bts-2-0-negrodorso-9cc59272b32d0b8aac17874366236354-480-0.webp" alt="" width="480" height="600" fetchpriority="high"></div>
<div class="portal-countdown" aria-label="Cuenta hasta el día del primer show"></div>
<span class="portal-index" aria-hidden="true">01</span>
</a>
<a class="portal-banner portal-kumo card-kumo" href="#kumo-preview" aria-label="Entrar a KUMØ · comparar tres propuestas">
<div class="portal-banner-copy"><span class="portal-eyebrow">ANIME / 雲</span><h2>KUMØ</h2><span class="portal-enter">VER KUMØ ↗</span></div>
<img class="portal-kumo-art" src="https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp" srcset="https://acdn-us.mitiendanube.com/stores/004/626/860/media/d9af73a8-kumo-480/source.webp 480w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/f31f98f0-kumo-960/source.webp 960w, https://acdn-us.mitiendanube.com/stores/004/626/860/media/ae3bff32-kumo-lossless/source.webp 1672w" sizes="(max-width: 600px) 60vw, 30vw" alt="" width="1920" height="960" loading="lazy" decoding="async">
<span class="portal-index" aria-hidden="true">02</span>
</a>
<a class="portal-banner portal-football card-futbol" href="#football-preview" aria-label="Entrar a 90 — comparar cinco propuestas">
<div class="portal-banner-copy"><span class="portal-eyebrow">FÚTBOL / ARCHIVO 90 MINUTOS</span><h2>90</h2><p>SELECCIÓN ARGENTINA / ÍDOLOS</p><span class="portal-enter">VER FÚTBOL ↗</span></div>
<div class="portal-football-art" aria-hidden="true"><span>90</span><i>FÚTBOL</i><b>ARG</b></div>
<span class="portal-index" aria-hidden="true">03</span>
</a>
<a class="portal-banner portal-artists card-artistas" href="#artistas-preview" aria-label="Entrar a ARTISTAS — comparar cinco propuestas">
<div class="portal-banner-copy"><span class="portal-eyebrow">ARTISTAS / BTS</span><h2>ARTISTAS</h2><p>OASIS / AIRBAG<br>BAD BUNNY / DUKI / TRUENO<br>LANZAMIENTO / BTS</p><span class="portal-enter">VER ARTISTAS ↗</span></div>
<div class="portal-record-art" aria-hidden="true"><span>ARTISTAS</span><span>BTS</span></div>
<span class="portal-index" aria-hidden="true">04</span>
</a>
<a class="portal-banner portal-f1" href="#f1-preview" aria-label="Entrar a F1 — comparar cinco propuestas">
<div class="portal-banner-copy"><span class="portal-eyebrow">MOTORSPORT</span><h2>F1</h2><p>COLAPINTO / FERRARI / MCLAREN</p><span class="portal-enter">VER F1 ↗</span></div><span class="portal-index" aria-hidden="true">05</span>
</a>
</div>
<div class="portal-bestsellers" aria-label="Más vendidos por universo"></div>
<div class="portal-trust-host"></div>
</section>
</div>

{% schema %}
{
  "name": "Home · portada y universos",
  "tags": ["general"],
  "icon": "CodeIcon",
  "settings": []
}
{% endschema %}
