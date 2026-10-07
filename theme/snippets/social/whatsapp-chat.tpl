{# WhatsApp chat button - Activado desde configuración de la tienda #}

{% if store.whatsapp %}
  <a
    href="{{ store.whatsapp }}"
    class="btn-whatsapp"
    target="_blank"
    rel="noopener noreferrer"
    aria-label="{{ 'general.contact_whatsapp' | t }}"
  >
    {% include 'snippets/icon.tpl' with { name: 'whatsapp', class: 'whatsapp-icon' } %}
  </a>
{% endif %}
