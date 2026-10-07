<!DOCTYPE html>
<html lang="{{ html_lang }}">
  <head>
    {# Meta tags component #}
    {{ component('head-tags') }}

    {# Google Fonts preconnect #}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    
    {# Preload critical assets #}
    <link rel="preload" as="style" href="{{ ([settings.font_headings, settings.font_rest] | merge(additional_fonts)) | google_fonts_url('400,700') }}" />
    <link rel="preload" href="{{ 'js/libraries-standalone.js' | static_url }}" as="script" />
    <link rel="preload" href="{{ 'css/style-critical.css' | static_url }}" as="style" />
    <link rel="preload" href="{{ 'css/style-utilities.css' | static_url }}" as="style" />

    {# Style Tokens (fonts + CSS custom properties) #}
    <style>
      {% include 'layouts/resources/style-tokens.tpl' %}
    </style>

    {# Critical CSS #}
    {{ 'css/style-critical.css' | static_url | static_inline }}

    {# Utilities CSS #}
    {{ 'css/style-utilities.css' | static_url | static_inline }}

    {# Async CSS loading #}
    <link rel="stylesheet" href="{{ 'css/style-async.css' | static_url }}" media="print" onload="this.media='all'">

    {# Custom CSS from settings #}
    {% if settings.css_code %}
      <style id="custom-theme-css">
        {{ settings.css_code | raw }}
      </style>
    {% endif %}

    {% set async_js = true %}

    {# Platform head content #}
    {% platform_head_content %}

    {# Structured data #}
    {% include 'snippets/structured-data/structured-data-organization.tpl' %}
    {% include 'snippets/structured-data/structured-data.tpl' %}

  </head>

  {% set cart_favicon_url = settings.cart_favicon ? (settings.cart_favicon | resolve_media).sourceUrl : '' %}

  <body
    class="{% if customer %}customer-logged-in{% endif %} template-{{ template | replace('.', '-') | replace('/', '-') }} {% if template == 'password' %}body-password{% endif %}"
    {% if settings.ajax_cart %}data-ajax-cart="true"{% endif %}
    {% if settings.inactive_tab_message %}
      data-inactive-tab-msg1="{{ settings.inactive_tab_message_01 | escape }}"
      data-inactive-tab-msg2="{{ settings.inactive_tab_message_02 | escape }}"
    {% endif %}
    {% if cart_favicon_url %}data-cart-favicon="{{ cart_favicon_url | escape }}"{% endif %}
    data-preview="{{ params.preview ? 'true' : 'false' }}"
  >
    {{ component('nubesdk-slot', { type: "before_main_content" }) }}

    {# SVG icons sprite #}
    {% include 'layouts/resources/icons-sprite.tpl' %}

    {# Back to admin bar #}
    {{ back_to_admin }}

    {# Header layout template - not shown on password page #}
    {% if template != 'password' %}
      <header class="js-header header">
        {% layout_template 'header' %}
      </header>
      {{ component('nubesdk-slot', { type: "after_header" }) }}
    {% endif %}

    {# Add to cart notification - Outside header for proper fixed positioning #}
    {% if settings.ajax_cart and template != 'password' %}
      {% include 'snippets/notification.tpl' with {
        type: 'add_to_cart',
      } %}
    {% endif %}

    {# Main content #}
    <main id="MainContent" class="main-content main-container" role="main">
      {{ page_template_content }}
    </main>

    {# Footer layout template - adapts automatically for password page #}
    {% layout_template 'footer' %}

    {% if template != 'password' %}
      {# Quick shop modal #}
      {% if settings.quick_shop %}
        {% include 'snippets/modals/quick-shop-modal.tpl' %}
      {% endif %}

      {# Cart modal - Ajax cart panel #}
      {% include 'snippets/cart/cart-modal.tpl' %}

      {# WhatsApp chat button #}
      {% include 'snippets/social/whatsapp-chat.tpl' %}

      {# Promotional modal #}
      {% if settings.promotional_popup_enabled %}
        {% include 'snippets/promotional-modal.tpl' %}
      {% endif %}

      {# Free shipping progress data #}
      <span class="js-ship-free-min hidden" data-pricemin="{{ cart.free_shipping.min_price_free_shipping.min_price_raw|default(0) }}"></span>
      <span class="js-free-shipping-config hidden" data-config="{{ cart.free_shipping.allFreeConfigurations }}"></span>
      <span class="js-cart-subtotal hidden" data-priceraw="{{ cart.subtotal }}"></span>
      <span class="js-cart-discount hidden" data-priceraw="{{ cart.promotional_discount_amount }}"></span>
    {% endif %}

    {# JavaScript - Standalone libraries (Swiper, Lazysizes) - blocking to guarantee availability #}
    {{ 'js/libraries-standalone.js' | static_url | script_tag }}

    {# JavaScript - Non-critical libraries and theme store: loaded after LS.ready #}
    <script>
      LS.ready.then(function() {

        {% include "static/js/libraries.js.tpl" %}

        var script = document.createElement('script');
        script.src = '{{ "js/store.js" | static_url }}';
        document.body.appendChild(script);
      });
    </script>

    {% platform_body_content %}
  </body>
</html>
