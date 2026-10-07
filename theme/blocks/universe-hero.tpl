{# MSMADE · Hero de universo en la categoría (ARTISTAS, NOVENTA).
   El módulo JS UniverseHero sube la sección al inicio de #MainContent y hace scroll suave al listado.
   Estilos: src/styles/modules/universe.css + universe-<id>.css #}

{% set universes = {
	'artistas': {
		'name': 'ARTISTAS / MÚSICA',
		'title': 'Tu música.<br>En primera fila.',
		'copy': 'Esas canciones, esas noches, esos artistas. Una colección para llevar lo que sentís.',
		'image': 'https://acdn-us.mitiendanube.com/stores/004/626/860/products/bad-2da-capsula-web-7-7ceb1771759d40bd0317694702395816-480-0.webp',
		'links': [
			{ 'url': '/artistas1/bad-bunny/', 'label': 'Bad Bunny' },
			{ 'url': '/artistas1/oasis/', 'label': 'Oasis' },
			{ 'url': '/artistas1/duki/', 'label': 'Duki' }
		]
	},
	'futbol': {
		'name': 'NOVENTA / FÚTBOL',
		'title': 'La pasión<br>se lleva puesta.',
		'copy': 'Los colores, los ídolos y esos momentos que quedan para siempre.',
		'image': 'https://acdn-us.mitiendanube.com/stores/004/626/860/products/mockup-arg-sol-dorso-c79e1c6ab24caed12717795896738994-480-0.webp',
		'links': [
			{ 'url': '/futbol-noventa/argentina/', 'label': 'Argentina' },
			{ 'url': '/futbol-noventa/idolos/', 'label': 'Ídolos' },
			{ 'url': '/futbol-noventa/ver-todo2/', 'label': 'Toda la colección' }
		]
	}
} %}
{% set universe_id = block.settings.universe | default('artistas') %}
{% set universe = universes[universe_id] %}

<div class="code-block block-fill" {{ block | block_attributes }} data-store="code-block-{{ block.id }}">
	<div class="universe universe-{{ universe_id }}" data-module="UniverseHero">
		<div class="universe-hero">
			<div>
				<a class="universe-back" href="/">← Todos los universos</a>
				<p class="universe-eyebrow">STREET 1640 · {{ universe.name }}</p>
				<h1>{{ universe.title | raw }}</h1>
				<p class="universe-copy">{{ universe.copy }}</p>
				<a class="universe-cta" href="#universo-productos">Explorar colección ↗</a>
			</div>
			<div class="universe-picture"><img src="{{ universe.image }}" alt="Prenda de la colección {{ universe.name }}" width="480" height="600"><span>DISEÑOS QUE TE REPRESENTAN</span></div>
		</div>
		<nav class="universe-nav" aria-label="Colecciones de {{ universe.name }}">
			{% for link in universe.links %}
				<a href="{{ link.url }}">{{ link.label }} ↗</a>
			{% endfor %}
		</nav>
	</div>
</div>

{% schema %}
{
  "name": "Universo · hero de categoría",
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
        { "value": "futbol", "label": "NOVENTA / FÚTBOL" }
      ],
      "default": "artistas"
    }
  ]
}
{% endschema %}
