{#
  Password Logo Section
  Header logo displayed on the store password page.
#}

<header class="head-main head-main-password">
  {% if has_logo %}
    {% include 'snippets/logo/logo-img.tpl' with { logo_size: 'large' } %}
  {% else %}
    {% include 'snippets/logo/logo-text.tpl' %}
  {% endif %}
</header>


{% schema %}
{
  "name": "t:names.password_logo",
  "wrapper": "header",
  "class": "section-password-logo",
  "static": true,
  "limit": 1,
  "presets": [{"name": "t:names.password_logo"}],
  "blocks": [],
  "enabled_on": {
    "page_templates": ["password"]
  }
}
{% endschema %}
