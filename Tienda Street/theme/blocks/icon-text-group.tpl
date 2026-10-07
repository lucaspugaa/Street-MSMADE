{# Icon Text Group Block - Container for icon-text items with layout control #}

{% set icon_position = block.settings.icon_position %}
{% set alignment = block.settings.alignment %}
{% set mobile_format = block.settings.mobile_format %}
{% set icon_size = block.settings.icon_size %}
{% set title_size = block.settings.title_size | default('h6') %}
{% set description_size = block.settings.description_size | default('paragraph_small') %}
{% set custom_title_font = block.settings.custom_title_font | default(settings.font_headings) %}
{% set custom_title_size = block.settings.custom_title_size %}
{% set custom_title_mobile = block.settings.custom_title_mobile %}
{% set custom_title_mobile_size = block.settings.custom_title_mobile_size %}
{% set gap = block.settings.gap %}
{% set show_icon = block.settings.show_icon is not same as(false) %}

{% set content_direction = icon_position == 'horizontal' ? 'horizontal' : 'vertical' %}
{% set item_count = block.blocks | length %}
{% set has_items = item_count > 0 %}

{% set use_slider = mobile_format == 'carousel' %}
{% set justify_class = alignment == 'center' ? 'justify-items-center' : (alignment == 'right' ? 'justify-items-end' : '') %}

<div class="icon-text-group w-100 text-{{ alignment }}" {{ block | block_attributes }} data-store="icon-text-group-{{ block.id }}">
	{% if has_items %}
		{% if use_slider %}
			<div class="js-icon-text-slider-container position-relative icon-text-slider-wrapper" data-gap="{{ gap }}" style="--grid-gap: {{ gap }}px;">
				<div class="js-icon-text-slider swiper-container">
					<div class="swiper-wrapper">
		{% else %}
			<div class="icon-text-grid {{ justify_class }}" style="--cols-md: {{ item_count }}; --grid-gap: {{ gap }}px; row-gap: {{ gap }}px;">
		{% endif %}
						{% for child_block in block.blocks %}
							{% if child_block and child_block.type is defined %}
								{% if use_slider %}
									<div class="swiper-slide d-flex justify-content-center">
								{% endif %}
									{% include 'blocks/' ~ child_block.type ~ '.tpl' with { block: child_block, content_direction: content_direction, icon_size: icon_size, alignment: alignment, title_size: title_size, description_size: description_size, custom_title_font: custom_title_font, custom_title_size: custom_title_size, custom_title_mobile: custom_title_mobile, custom_title_mobile_size: custom_title_mobile_size, show_icon: show_icon } %}
								{% if use_slider %}
									</div>
								{% endif %}
							{% endif %}
						{% endfor %}
		{% if use_slider %}
					</div>
				</div>
				{% if item_count > 1 %}
					<div class="js-swiper-icon-text-pagination swiper-pagination swiper-pagination-outside d-md-none"></div>
				{% endif %}
			</div>
		{% else %}
			</div>
		{% endif %}
	{% endif %}
</div>

{% schema %}
{
  "name": "t:names.icon_text_group",
  "icon": "FolderIcon",
  "deletable": false,
  "limit": 1,
  "blocks": [
    { "type": "icon-text-item", "limit": 6 }
  ],
  "settings": [
    {
      "type": "header",
      "content": "t:names.disposition"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "show_icon",
      "label": "t:settings.show_icon",
      "default": true
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "icon_position",
      "label": "t:settings.icon_position",
      "options": [
        { "value": "vertical", "label": "t:options.icon_top" },
        { "value": "horizontal", "label": "t:options.icon_left" }
      ],
      "default": "horizontal",
      "visible_if": "{{ block.settings.show_icon }}"
    },
    {
      "type": "setting",
      "setting_type": "text_alignment",
      "id": "alignment",
      "label": "t:settings.alignment",
      "options": [
        { "value": "left", "label": "t:options.left" },
        { "value": "center", "label": "t:options.center" },
        { "value": "right", "label": "t:options.right" }
      ],
      "default": "left"
    },
    {
      "type": "setting",
      "setting_type": "radio",
      "id": "mobile_format",
      "label": "t:settings.mobile_presentation",
      "options": [
        { "value": "list", "label": "t:options.vertical_list" },
        { "value": "carousel", "label": "t:options.slider" }
      ],
      "default": "carousel"
    },
    {
      "type": "header",
      "content": "t:names.design"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "icon_size",
      "label": "t:settings.icon_size",
      "min": 16,
      "max": 120,
      "step": 1,
      "unit": "px",
      "default": 32,
      "icon": "horizontal_spacing",
      "visible_if": "{{ block.settings.show_icon }}"
    },
    {
      "type": "setting",
      "setting_type": "heading_select",
      "id": "title_size",
      "label": "t:settings.title_style",
      "options": [
        { "value": "h1", "label": "t:options.heading_1" },
        { "value": "h2", "label": "t:options.heading_2" },
        { "value": "h3", "label": "t:options.heading_3" },
        { "value": "h4", "label": "t:options.heading_4" },
        { "value": "h5", "label": "t:options.heading_5" },
        { "value": "h6", "label": "t:options.heading_6" },
        { "value": "paragraph", "label": "t:options.paragraph" },
        { "value": "paragraph_small", "label": "t:options.paragraph_small" },
        { "value": "custom", "label": "t:options.custom" }
      ],
      "default": "h6"
    },
    {
      "type": "setting",
      "setting_type": "font_picker",
      "id": "custom_title_font",
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
      "visible_if": "{{ block.settings.title_size == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "custom_title_size",
      "label": "t:settings.size",
      "min": 12,
      "max": 120,
      "step": 1,
      "unit": "px",
      "default": 18,
      "visible_if": "{{ block.settings.title_size == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "toggle",
      "id": "custom_title_mobile",
      "label": "t:settings.mobile_font_size",
      "visible_if": "{{ block.settings.title_size == 'custom' }}"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "custom_title_mobile_size",
      "label": "t:settings.mobile_size",
      "min": 12,
      "max": 120,
      "step": 1,
      "unit": "px",
      "default": 18,
      "visible_if": "{{ block.settings.title_size == 'custom' and block.settings.custom_title_mobile }}"
    },
    {
      "type": "setting",
      "setting_type": "select",
      "id": "description_size",
      "label": "t:settings.description_size",
      "options": [
        { "value": "paragraph_small", "label": "t:options.paragraph_small" },
        { "value": "paragraph", "label": "t:options.paragraph" },
        { "value": "paragraph_big", "label": "t:options.paragraph_big" }
      ],
      "default": "paragraph_small"
    },
    {
      "type": "setting",
      "setting_type": "range",
      "id": "gap",
      "label": "t:settings.gap",
      "min": 0,
      "max": 50,
      "step": 4,
      "unit": "px",
      "default": 16,
      "icon": "horizontal_spacing"
    }
  ]
}
{% endschema %}
