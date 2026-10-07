{# Heading Block - Public, can be used anywhere #}
{#
   SEO Note: This block always renders as <p> with visual heading classes.
   This prevents multiple H1 tags on a page. Real semantic headings (H1)
   should be defined in page templates (product, category, contact, etc.)
#}

{% set heading_settings = block.settings %}
{% set block_width = heading_settings.width | default('fill') %}
{% set heading_size = heading_settings.size %}
{% set heading_mobile = heading_settings.mobile_font_size %}
{% set is_custom = heading_size == 'custom' %}

{% set fill_class = block_width == 'fill' ? ' block-fill' %}

{% if is_custom %}
	{% set custom_font = heading_settings.custom_font | default(settings.font_headings) %}
	{% set custom_size = heading_settings.custom_font_size | default((settings.headings_size * 0.583) | round) %}
	{% set heading_style = '--block-font: ' ~ custom_font ~ '; --block-font-size: ' ~ custom_size ~ 'px;' %}
	{% if heading_mobile and heading_settings.custom_mobile_font_size %}
		{% set heading_style = heading_style ~ ' --block-mobile-font-size: ' ~ heading_settings.custom_mobile_font_size ~ 'px;' %}
	{% endif %}
	{% set heading_class = 'heading-block heading-custom' ~ fill_class %}
{% else %}
	{% set heading_class = 'heading-block ' ~ heading_size %}
	{% if heading_mobile %}
		{% set heading_class = heading_class ~ '-md ' ~ heading_settings.mobile_size %}
	{% endif %}
	{% set heading_class = heading_class ~ fill_class %}
{% endif %}

{% if heading_settings.title %}
	<div
		class="{{ heading_class }}"
		{{ block | block_attributes }}
		data-store="heading-block-{{ block.id }}"
		{% if heading_style %}style="{{ heading_style }}"{% endif %}
	>
		{{ heading_settings.title | raw }}
	</div>
{% endif %}

{% schema %}
{
  "name": "t:names.heading",
  "tags": ["general"],
  "category": "basic",
  "icon": "TextSizeIcon",
  "settings": [
    {
      "type": "setting",
      "setting_type": "richtext",
      "id": "title",
      "label": "t:options.text",
      "default": "t:defaults.heading"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "width",
      "label": "t:settings.section_width",
      "options": [
        { "value": "fit", "label": "t:options.fit" },
        { "value": "fill", "label": "t:options.fill" }
      ],
      "default": "fill"
    },
    {
      "type": "header",
      "content": "t:names.text_settings"
    },
    {
      "type": "setting",
      "setting_type": "heading_select",
      "id": "size",
      "label": "t:settings.style",
      "options": [
        { "value": "h1", "label": "t:options.heading_1" },
        { "value": "h2", "label": "t:options.heading_2" },
        { "value": "h3", "label": "t:options.heading_3" },
        { "value": "h4", "label": "t:options.heading_4" },
        { "value": "h5", "label": "t:options.heading_5" },
        { "value": "h6", "label": "t:options.heading_6" },
        { "value": "custom", "label": "t:options.custom" }
      ],
      "default": "h4"
    },
    {
      "type": "setting",
      "setting_type": "font_picker",
      "id": "custom_font",
      "label": "t:settings.font",
      "default_setting": "font_headings",
      "options": [
        { "value": "\"Albert Sans\", sans-serif", "label": "Albert Sans" },
        { "value": "\"Almarai\", sans-serif", "label": "Almarai" },
        { "value": "\"Archivo\", sans-serif", "label": "Archivo" },
        { "value": "\"Archivo Black\", sans-serif", "label": "Archivo Black" },
        { "value": "\"Arimo\", sans-serif", "label": "Arimo" },
        { "value": "\"Arvo\", serif", "label": "Arvo" },
        { "value": "\"Big Shoulders Display\", sans-serif", "label": "Big Shoulders Display" },
        { "value": "\"Bitter\", serif", "label": "Bitter" },
        { "value": "\"Braah One\", sans-serif", "label": "Braah One" },
        { "value": "\"Bree Serif\", serif", "label": "Bree Serif" },
        { "value": "\"Buenard\", serif", "label": "Buenard" },
        { "value": "\"Chakra Petch\", sans-serif", "label": "Chakra Petch" },
        { "value": "\"Chivo\", sans-serif", "label": "Chivo" },
        { "value": "\"Corben\", serif", "label": "Corben" },
        { "value": "\"DM Sans\", sans-serif", "label": "DM Sans" },
        { "value": "\"Domine\", serif", "label": "Domine" },
        { "value": "\"Droid Sans\", sans-serif", "label": "Droid Sans" },
        { "value": "\"Droid Serif\", serif", "label": "Droid Serif" },
        { "value": "\"Figtree\", sans-serif", "label": "Figtree" },
        { "value": "\"Fraunces\", serif", "label": "Fraunces" },
        { "value": "\"Fredoka One\", sans-serif", "label": "Fredoka One" },
        { "value": "\"Gabarito\", sans-serif", "label": "Gabarito" },
        { "value": "\"Gilda Display\", serif", "label": "Gilda Display" },
        { "value": "\"Golos Text\", sans-serif", "label": "Golos Text" },
        { "value": "\"Handlee\", cursive", "label": "Handlee" },
        { "value": "\"IBM Plex Sans\", sans-serif", "label": "IBM Plex Sans" },
        { "value": "\"IBM Plex Serif\", serif", "label": "IBM Plex Serif" },
        { "value": "\"Instrument Sans\", sans-serif", "label": "Instrument Sans" },
        { "value": "\"Inter\", sans-serif", "label": "Inter" },
        { "value": "\"Istok Web\", sans-serif", "label": "Istok Web" },
        { "value": "\"Italiana\", serif", "label": "Italiana" },
        { "value": "\"Josefin Sans\", sans-serif", "label": "Josefin Sans" },
        { "value": "\"Kanit\", sans-serif", "label": "Kanit" },
        { "value": "\"Karla\", sans-serif", "label": "Karla" },
        { "value": "\"Lato\", sans-serif", "label": "Lato" },
        { "value": "\"League Spartan\", sans-serif", "label": "League Spartan" },
        { "value": "\"Lexend\", sans-serif", "label": "Lexend" },
        { "value": "\"Lexend Exa\", sans-serif", "label": "Lexend Exa" },
        { "value": "\"Libre Baskerville\", serif", "label": "Libre Baskerville" },
        { "value": "\"Libre Franklin\", sans-serif", "label": "Libre Franklin" },
        { "value": "\"Literata\", serif", "label": "Literata" },
        { "value": "\"Lora\", serif", "label": "Lora" },
        { "value": "\"Manrope\", sans-serif", "label": "Manrope" },
        { "value": "\"Marcellus\", serif", "label": "Marcellus" },
        { "value": "\"Montserrat\", sans-serif", "label": "Montserrat" },
        { "value": "\"Muli\", sans-serif", "label": "Muli" },
        { "value": "\"Neuton\", serif", "label": "Neuton" },
        { "value": "\"Niramit\", sans-serif", "label": "Niramit" },
        { "value": "\"Nunito\", sans-serif", "label": "Nunito" },
        { "value": "\"Onest\", sans-serif", "label": "Onest" },
        { "value": "\"Oooh Baby\", cursive", "label": "Oooh Baby" },
        { "value": "\"Open Sans\", sans-serif", "label": "Open Sans" },
        { "value": "\"Oswald\", sans-serif", "label": "Oswald" },
        { "value": "\"Outfit\", sans-serif", "label": "Outfit" },
        { "value": "\"Paytone One\", sans-serif", "label": "Paytone One" },
        { "value": "\"Piazzolla\", serif", "label": "Piazzolla" },
        { "value": "\"Playfair Display\", serif", "label": "Playfair Display" },
        { "value": "\"Pliant\", sans-serif", "label": "Pliant" },
        { "value": "\"Plus Jakarta Sans\", sans-serif", "label": "Plus Jakarta Sans" },
        { "value": "\"Poppins\", sans-serif", "label": "Poppins" },
        { "value": "\"Prata\", serif", "label": "Prata" },
        { "value": "\"PT Sans Narrow\", sans-serif", "label": "PT Sans Narrow" },
        { "value": "\"Public Sans\", sans-serif", "label": "Public Sans" },
        { "value": "\"Raleway\", sans-serif", "label": "Raleway" },
        { "value": "\"Readex Pro\", sans-serif", "label": "Readex Pro" },
        { "value": "\"Red Hat Display\", sans-serif", "label": "Red Hat Display" },
        { "value": "\"Roboto\", sans-serif", "label": "Roboto" },
        { "value": "\"Roboto Condensed\", sans-serif", "label": "Roboto Condensed" },
        { "value": "\"Roboto Mono\", sans-serif", "label": "Roboto Mono" },
        { "value": "\"Rubik\", sans-serif", "label": "Rubik" },
        { "value": "\"Slabo 27px\", serif", "label": "Slabo 27px" },
        { "value": "\"Sofia Sans Extra Condensed\", sans-serif", "label": "Sofia Sans Extra Condensed" },
        { "value": "\"Sora\", sans-serif", "label": "Sora" },
        { "value": "\"Source Sans Pro\", sans-serif", "label": "Source Sans Pro" },
        { "value": "\"Space Grotesk\", sans-serif", "label": "Space Grotesk" },
        { "value": "\"Tenor Sans\", sans-serif", "label": "Tenor Sans" },
        { "value": "\"Ubuntu\", sans-serif", "label": "Ubuntu" },
        { "value": "\"Ubuntu Mono\", monospace", "label": "Ubuntu Mono" },
        { "value": "\"Ultra\", serif", "label": "Ultra" },
        { "value": "\"Unna\", serif", "label": "Unna" },
        { "value": "\"Work Sans\", sans-serif", "label": "Work Sans" },
        { "value": "\"Zalando Sans\", sans-serif", "label": "Zalando Sans" },
        { "value": "\"Zalando Sans Expanded\", sans-serif", "label": "Zalando Sans Expanded" },
        { "value": "\"Zen Kaku Gothic New\", sans-serif", "label": "Zen Kaku Gothic New" },
        { "value": "\"Zilla Slab\", serif", "label": "Zilla Slab" }
      ],
      "visible_if": "{{ block.settings.size == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "custom_font_size",
      "label": "t:settings.size",
      "min": 12,
      "max": 200,
      "step": 1,
      "unit": "px",
      "default": 28,
      "visible_if": "{{ block.settings.size == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "mobile_font_size",
      "label": "t:settings.mobile_font_size"
    },
    {
      "type": "setting",
      "setting_type": "heading_select",
      "id": "mobile_size",
      "label": "t:settings.mobile_size",
      "options": [
        { "value": "h1", "label": "t:options.heading_1" },
        { "value": "h2", "label": "t:options.heading_2" },
        { "value": "h3", "label": "t:options.heading_3" },
        { "value": "h4", "label": "t:options.heading_4" },
        { "value": "h5", "label": "t:options.heading_5" },
        { "value": "h6", "label": "t:options.heading_6" }
      ],
      "default": "h4",
      "visible_if": "{{ block.settings.mobile_font_size and block.settings.size != 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "custom_mobile_font_size",
      "label": "t:settings.mobile_size",
      "min": 12,
      "max": 200,
      "step": 1,
      "unit": "px",
      "default": 28,
      "visible_if": "{{ block.settings.mobile_font_size and block.settings.size == 'custom' }}"
    }
  ],
  "presets": [
    {
      "name": "t:names.heading",
      "category": "t:categories.basic",
      "settings": {
        "title": "t:defaults.heading"
      }
    }
  ]
}
{% endschema %}
