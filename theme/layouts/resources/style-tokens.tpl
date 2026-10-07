{# /* Style tokens */ #}

{#/*============================================================================
  #Font imports
==============================================================================*/#}

{% set font_weights = font_weights|default('400,700') %}
{% set additional_fonts = additional_fonts|default([]) %}
{% set selected_fonts = font_settings|default('settings.font_headings, settings.font_rest')|split(',')|map(s => attribute(settings, s|trim|split('.')|last)) %}

{% set fonts = [
	'Albert+Sans',
	'Almarai',
	'Archivo',
	'Archivo Black',
	'Arimo',
	'Arvo',
	'Big+Shoulders+Display',
	'Bitter',
	'Braah+One',
	'Bree+Serif',
	'Buenard',
	'Chakra+Petch',
	'Chivo',
	'Corben',
	'DM+Sans',
	'Domine',
	'Droid+Sans',
	'Droid+Serif',
	'Figtree',
	'Fraunces',
	'Fredoka+One',
	'Gabarito',
	'Gilda+Display',
	'Golos+Text',
	'Handlee',
	'IBM+Plex+Sans',
	'IBM+Plex+Serif',
	'Instrument+Sans',
	'Inter',
	'Istok+Web',
	'Italiana',
	'Josefin+Sans',
	'Kanit',
	'Karla',
	'Lato',
	'League+Spartan',
	'Lexend',
	'Lexend+Exa',
	'Libre+Baskerville',
	'Libre+Franklin',
	'Literata',
	'Lora',
	'Manrope',
	'Marcellus',
	'Montserrat',
	'Muli',
	'Neuton',
	'Niramit',
	'Nunito',
	'Onest',
	'Open+Sans',
	'Oooh+Baby',
	'Oswald',
	'Outfit',
	'Paytone+One',
	'Piazzolla',
	'Playfair+Display',
	'Pliant',
	'Plus+Jakarta+Sans',
	'Poppins',
	'Prata',
	'PT+Sans+Narrow',
	'Public+Sans',
	'Raleway',
	'Red+Hat+Display',
	'Readex+Pro',
	'Roboto',
	'Roboto+Condensed',
	'Roboto+Mono',
	'Rubik',
	'Slabo+27px',
	'Sofia+Sans+Extra+Condensed',
	'Sora',
	'Source+Sans+Pro',
	'Space+Grotesk',
	'Tenor+Sans',
	'Ubuntu',
	'Ubuntu+Mono',
	'Ultra',
	'Unna',
	'Work+Sans',
	'Zalando+Sans',
	'Zalando+Sans+Expanded',
	'Zen+Kaku+Gothic+New',
	'Zilla+Slab'
] %}

{% if params.preview %}

	{% set font_families = [] %}
	{% for font in fonts %}
		{% set font_families = font_families|merge([font ~ ':' ~ font_weights]) %}
	{% endfor %}

	@import url('https://fonts.googleapis.com/css?family={{ font_families|join('|') }}');

{% else %}

	{% set all_fonts = selected_fonts | merge(additional_fonts) %}
	@import url('{{ all_fonts | google_fonts_url(font_weights) | raw }}');

{% endif %}

{#/*============================================================================
  #CSS Custom Properties
==============================================================================*/#}

:root {

  {#/*============================================================================
    #Colors
  ==============================================================================*/#}

  {# Main colors #}

  {% set main_background = settings.background_color %}
  {% set main_foreground = settings.text_color %}

  {% set accent_color = settings.accent_color %}

  {% set button_primary_background = settings.button_primary_background_color %}
  {% set button_primary_foreground = settings.button_primary_foreground_color %}
  {% set button_primary_style = settings.button_primary_style %}
  {% set button_primary_border_radius = settings.button_primary_border_radius %}

  {% set button_secondary_background = settings.button_secondary_background_color %}
  {% set button_secondary_foreground = settings.button_secondary_foreground_color %}
  {% set button_secondary_style = settings.button_secondary_style %}
  {% set button_secondary_border_radius = settings.button_secondary_border_radius %}

  {% set button_tertiary_background = settings.button_tertiary_background_color %}
  {% set button_tertiary_foreground = settings.button_tertiary_foreground_color %}
  {% set button_tertiary_style = settings.button_tertiary_style %}
  {% set button_tertiary_border_radius = settings.button_tertiary_border_radius %}

  {% set label_background = settings.label_background_color %}
  {% set label_foreground = settings.label_foreground_color %}
  {% set label_style = settings.label_style | default('filled') %}
  {% set label_border_radius = settings.label_border_radius | default(4) %}

  {% set label_shipping_background = settings.label_shipping_background_color %}
  {% set label_shipping_foreground = settings.label_shipping_foreground_color %}
  {% set label_shipping_style = settings.label_shipping_style | default('filled') %}
  {% set label_shipping_border_radius = settings.label_shipping_border_radius | default(4) %}

  --main-background: {{ main_background }};
  --main-foreground: {{ main_foreground }};

  --accent-color: {{ accent_color }};

  --button-primary-background-color: {{ button_primary_background }};
  --button-primary-foreground-color: {{ button_primary_foreground }};

  --button-primary-border-radius: {{ button_primary_border_radius }}px;
  {% if button_primary_style == 'outline' %}
    --button-primary-background: {{ button_primary_background }};
    --button-primary-border: 1px solid {{ button_primary_foreground }};
    --button-primary-color: {{ button_primary_foreground }};
    --button-primary-fill: {{ button_primary_foreground }};
  {% else %}
    --button-primary-background: {{ button_primary_background }};
    --button-primary-border: 0;
    --button-primary-color: {{ button_primary_foreground }};
    --button-primary-fill: {{ button_primary_foreground }};
  {% endif %}

  --button-secondary-border-radius: {{ button_secondary_border_radius }}px;
  {% if button_secondary_style == 'filled' %}
    --button-secondary-background: {{ button_secondary_background }};
    --button-secondary-border: 0;
    --button-secondary-color: {{ button_secondary_foreground }};
    --button-secondary-fill: {{ button_secondary_foreground }};
    --button-secondary-text-decoration: none;
  {% elseif button_secondary_style == 'outline' %}
    --button-secondary-background: {{ button_secondary_background }};
    --button-secondary-border: 1px solid {{ button_secondary_foreground }};
    --button-secondary-color: {{ button_secondary_foreground }};
    --button-secondary-fill: {{ button_secondary_foreground }};
    --button-secondary-text-decoration: none;
  {% else %}
    --button-secondary-background: transparent;
    --button-secondary-border: 0;
    --button-secondary-color: {{ button_secondary_foreground }};
    --button-secondary-fill: {{ button_secondary_foreground }};
    --button-secondary-text-decoration: underline;
  {% endif %}

  --button-tertiary-border-radius: {{ button_tertiary_border_radius }}px;
  {% if button_tertiary_style == 'filled' %}
    --button-tertiary-background: {{ button_tertiary_background or 'transparent' }};
    --button-tertiary-border: 0;
    --button-tertiary-color: {{ button_tertiary_foreground }};
    --button-tertiary-fill: {{ button_tertiary_foreground }};
    --button-tertiary-text-decoration: none;
  {% elseif button_tertiary_style == 'outline' %}
    --button-tertiary-background: {{ button_tertiary_background or 'transparent' }};
    --button-tertiary-border: 1px solid {{ button_tertiary_foreground }};
    --button-tertiary-color: {{ button_tertiary_foreground }};
    --button-tertiary-fill: {{ button_tertiary_foreground }};
    --button-tertiary-text-decoration: none;
  {% else %}
    --button-tertiary-background: transparent;
    --button-tertiary-border: 0;
    --button-tertiary-color: {{ button_tertiary_foreground }};
    --button-tertiary-fill: {{ button_tertiary_foreground }};
    --button-tertiary-text-decoration: underline;
  {% endif %}

  --label-primary-background: {{ label_background }};
  --label-primary-foreground: {{ label_foreground }};
  --label-primary-border-radius: {{ label_border_radius }}px;
  {% if label_style == 'outline' %}
    --label-primary-border: 1px solid {{ label_foreground }};
  {% else %}
    --label-primary-border: 0;
  {% endif %}

  --label-secondary-background: {{ label_shipping_background }};
  --label-secondary-foreground: {{ label_shipping_foreground }};
  --label-secondary-border-radius: {{ label_shipping_border_radius }}px;
  {% if label_shipping_style == 'outline' %}
    --label-secondary-border: 1px solid {{ label_shipping_foreground }};
  {% else %}
    --label-secondary-border: 0;
  {% endif %}

  {# Color shades #}

  {% set opacity_03 = '08' %}
  {% set opacity_05 = '0D' %}
  {% set opacity_08 = '14' %}
  {% set opacity_10 = '1A' %}
  {% set opacity_20 = '33' %}
  {% set opacity_30 = '4D' %}
  {% set opacity_40 = '66' %}
  {% set opacity_50 = '80' %}
  {% set opacity_60 = '99' %}
  {% set opacity_70 = 'B3' %}
  {% set opacity_80 = 'CC' %}
  {% set opacity_90 = 'E6' %}
  {% set opacity_95 = 'F2' %}

  --main-foreground-opacity-03: {{ main_foreground }}{{ opacity_03 }};
  --main-foreground-opacity-05: {{ main_foreground }}{{ opacity_05 }};
  --main-foreground-opacity-10: {{ main_foreground }}{{ opacity_10 }};
  --main-foreground-opacity-20: {{ main_foreground }}{{ opacity_20 }};
  --main-foreground-opacity-30: {{ main_foreground }}{{ opacity_30 }};
  --main-foreground-opacity-40: {{ main_foreground }}{{ opacity_40 }};
  --main-foreground-opacity-50: {{ main_foreground }}{{ opacity_50 }};
  --main-foreground-opacity-60: {{ main_foreground }}{{ opacity_60 }};

  --main-background-opacity-30: {{ main_background }}{{ opacity_30 }};
  --main-background-opacity-50: {{ main_background }}{{ opacity_50 }};
  --main-background-opacity-80: {{ main_background }}{{ opacity_80 }};

  --label-secondary-background-80: {{ label_shipping_background }}{{ opacity_80 }};

  {# Alert colors #}

  --success: #4bb98c;
  --danger: #dd7774;
  --warning: #dc8f38;

  {#/*============================================================================
    #Fonts
  ==============================================================================*/#}

  {# Font families #}

  --heading-font: {{ settings.font_headings | raw }};
  --body-font: {{ settings.font_rest | raw }};

  {# Font sizes #}

  {% set font_base_size = settings.font_base_size %}

  --font-base: {{ font_base_size }}px;
  --font-base-default: 16px;

  {% set font_rest_size = settings.font_rest_size %}

  --font-huge: {{ font_rest_size + 10 }}px;
  --font-big: {{ font_rest_size + 4 }}px;
  --font-medium: {{ font_rest_size + 2 }}px;
  --font-small: {{ font_rest_size }}px;
  --font-smallest: {{ font_rest_size - 2 }}px;
  --font-extra-smallest: {{ font_rest_size - 3 }}px;

  {# Scales using 1.2 minor third scale #}

  {% set heading_size = settings.headings_size %}

  --h1: {{ heading_size }}px;
  --h2: {{ (heading_size * 0.833) | round }}px;
  --h3: {{ (heading_size * 0.6875) | round }}px;
  --h4: {{ (heading_size * 0.583) | round }}px;
  --h5: {{ (heading_size * 0.479) | round }}px;
  --h6: {{ (heading_size * 0.396) | round }}px;
  --h6-small: {{ (heading_size * 0.3333) | round }}px;

  {# Titles weight #}

  {% set title_weight = settings.headings_bold ? '700' : '400' %}

  --title-font-weight: {{ title_weight }};

  {#/*============================================================================
    #Layout
  ==============================================================================*/#}

  {# Spacing #}

  --spacing-base: 16px;
  --spacing-half: calc(var(--spacing-base) / 2);
  --spacing-quarter: calc(var(--spacing-base) / 4);

  --spacing-1: calc(var(--spacing-base) * 0.25);
  --spacing-2: calc(var(--spacing-base) * 0.5);
  --spacing-3: var(--spacing-base);
  --spacing-4: calc(var(--spacing-base) * 1.5);
  --spacing-5: calc(var(--spacing-base) * 3);

  --spacing-section: calc(var(--spacing-base) * 4);
  --spacing-section-small: calc(var(--spacing-base) * 2);

  {# Section content - lateral padding in full-width divided sections #}

  --section-content-lateral-padding: calc(var(--spacing-base) * 5);

  {# Icon sizes (em-based, scale relative to parent font-size) #}

  --icon-size-md: 0.875em;
  --icon-size-lg: 1.33em;
  --icon-size-2x: 2em;

  {# Gutters #}

  --gutter: var(--spacing-base);
  --gutter-container: var(--gutter);
  --gutter-container-md: calc(var(--gutter) * 2);
  --gutter-negative: calc(var(--gutter) * -1);
  --gutter-half: calc(var(--gutter) / 2);
  --gutter-half-negative: calc(var(--gutter) * -1 / 2);
  --gutter-double: calc(var(--gutter) * 2);

  {# Page width #}

  {% set page_width = settings.page_width|default(1300) %}
  --page-width: {{ page_width }}px;

  {#/*============================================================================
    #Misc
  ==============================================================================*/#}

  {# Transitions #}

  --transition-fast: all 0.2s ease;
  --transition-normal: all 0.3s ease;
  --transition-slow: all 1s ease;

  {# Shadows #}

  --drop-shadow: 0 0 8px 4px var(--main-foreground-opacity-05);

  {# Border radius #}

  --border-radius: 8px;
  --border-radius-medium: calc(var(--border-radius) / 1.3333);
  --border-radius-small: calc(var(--border-radius) / 2);
  --border-radius-smallest: calc(var(--border-radius) / 4);
  --border-radius-full: 100%;

  {# Border stroke #}

  --border-solid: 1px solid;
}
