{# MSMADE · Universo en la ficha de producto: franja "Volver a …" + guía de compra.
   El módulo JS ProductUniverse sube la franja al inicio de #MainContent y pone la guía después del producto.
   Estilos: src/styles/modules/product-universe.css #}

{% set universes = {
	'artistas': { 'url': '/artistas1/', 'name': 'ARTISTAS / MÚSICA', 'guide_title': 'Tu artista. Tu estilo.' },
	'futbol': { 'url': '/futbol-noventa/', 'name': 'NOVENTA / FÚTBOL', 'guide_title': 'Los colores se eligen. La pasión se lleva.' },
	'kumo': { 'url': '/anime/', 'name': 'KUMØ / ANIME', 'guide_title': 'Una prenda. Toda una historia.' }
} %}
{% set universe_id = block.settings.universe | default('artistas') %}
{% set universe = universes[universe_id] %}

<div class="code-block block-fill" {{ block | block_attributes }} data-store="code-block-{{ block.id }}">
	<div class="product-universe product-{{ universe_id }}" data-module="ProductUniverse"><a href="{{ universe.url }}">← Volver a {{ universe.name }}</a><span>STREET 1640 · {{ universe.name }}</span></div>
	<aside class="product-universe-guide">
		<h2>{{ universe.guide_title }}</h2>
		<div>
			<p><strong>Encontrá tu combinación</strong><br>Elegí color y talle entre las opciones disponibles para esta prenda.</p>
			<p><strong>Conocé cada detalle</strong><br>Consultá la descripción del producto para ver sus características.</p>
			<p><strong>¿Tenés dudas sobre el talle?</strong><br><a href="/contacto/">Escribinos antes de comprar ↗</a></p>
		</div>
	</aside>
</div>

{% schema %}
{
  "name": "Universo · ficha de producto",
  "tags": ["general"],
  "icon": "CodeIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "select",
      "id": "universe",
      "label": "Universo",
      "options": [
        { "value": "artistas", "label": "ARTISTAS / MÚSICA" },
        { "value": "futbol", "label": "NOVENTA / FÚTBOL" },
        { "value": "kumo", "label": "KUMØ / ANIME" }
      ],
      "default": "artistas"
    }
  ]
}
{% endschema %}
