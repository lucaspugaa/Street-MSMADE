{#
  Logo Text
  Store name as text when no logo image.
#}
<div id="no-logo" class="logo-text-container">
    <a class="logo-text" href="{{ store.url }}">
        {% if template == 'home' %}
            <h1 class="logo-text">{{ store.name }}</h1>
        {% else %}
            {{ store.name }}
        {% endif %}
    </a>
</div>
