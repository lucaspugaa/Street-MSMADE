{# MSMADE · Universo KUMØ (Anime) en la categoría: anuncio, masthead, menú, banner, intro, mundos y outro.
   El módulo JS KumoStore sube la sección al inicio de #MainContent, manda el outro al final y hace scroll suave al catálogo.
   Estilos: src/styles/modules/kumo.css #}

<div class="code-block block-fill" {{ block | block_attributes }} data-store="code-block-{{ block.id }}">
	<div class="kumo-store" data-module="KumoStore">
		<div class="kumo-announcement">KUMØ · 雲 · ANIME &amp; STREETWEAR <span>UNA HISTORIA PARA CADA PRENDA</span></div>
		<div class="kumo-masthead"><a href="/" class="kumo-return">← STREET / UNIVERSOS</a><a class="kumo-wordmark" href="/anime/" aria-label="KUMO Anime">KUMØ <small>雲</small></a><a href="#kumo-catalogo" class="kumo-shop">EXPLORAR ↗</a></div>
		<nav class="kumo-menu" aria-label="Colecciones Anime">
			<a href="#kumo-catalogo">COLECCIÓN</a>
			<a href="/anime/one-piece/">ONE PIECE</a>
			<a href="/anime/dragon-ball/">DRAGON BALL</a>
			<a href="/anime/naruto/">NARUTO</a>
			<a href="/anime/demon-slayer/">DEMON SLAYER</a>
		</nav>
		<a class="kumo-banner" href="/anime/one-piece/" aria-label="Explorar la colección One Piece"><img src="https://acdn-us.mitiendanube.com/stores/007/780/308/themes/rio/2-slide-1780346719926-3702081623-c12fb462ac3156a2ba879a08e038ebcf1780346730-1920-1920.webp?7200573017152359550" alt="KUMØ · Drop 001 Grand Line: estética nocturna y urbana" fetchpriority="high"><span>EXPLORAR ONE PIECE ↗</span></a>
		<div class="kumo-intro"><span>雲 / CULTURA ANIME</span><h1>Tu universo.<br>Fuera de la pantalla.</h1><p>Personajes, símbolos e historias que forman parte de vos.<br>Encontrá tu próxima prenda en KUMØ.</p></div>
		<div class="kumo-worlds">
			<a href="/anime/one-piece/"><span>01 / GRAND LINE</span><strong>ONE<br>PIECE</strong><i>Encontrá tu tripulación ↗</i></a>
			<a href="/anime/dragon-ball/"><span>02 / SIN LÍMITES</span><strong>DRAGON<br>BALL</strong><i>Llevá tu energía ↗</i></a>
			<a href="/anime/naruto/"><span>03 / TU CAMINO</span><strong>NARUTO</strong><i>Seguí tu propio camino ↗</i></a>
		</div>
		<div class="kumo-collection-heading"><span>EL PRÓXIMO CAPÍTULO</span><h2>La colección</h2><p>Explorá los diseños y elegí tu historia.</p></div>
		<div class="kumo-outro"><span>KUMØ / 雲</span><h2>Las historias siguen.<br>Tu estilo también.</h2><div><a href="/contacto/">Hablemos de tu próxima prenda ↗</a><a href="/">Volver a todos los universos ↗</a></div></div>
	</div>
</div>

{% schema %}
{
  "name": "Universo · KUMØ (categoría)",
  "tags": ["general"],
  "icon": "CodeIcon",
  "settings": []
}
{% endschema %}
