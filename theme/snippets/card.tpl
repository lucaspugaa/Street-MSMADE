{# /*============================================================================
  #Card
==============================================================================*/

#Head
    // Block - card_head
#Body
    // Block - card_body
#Footer
    // Block - card_footer

#}


<div class="{% if card_collapse %}js-accordion-private-container {% endif %}card {{ card_custom_class }} {% if card_active %}active{% endif %}">
    <div class="card-header {% if card_collapse %}card-header-collapsible{% endif %}">
        {% block card_head %}{% endblock %}
        {% if card_collapse %}
            <button class="js-accordion-private-toggle">
                <svg class="js-accordion-private-toggle-active card-toggle-icon icon-inline"><use xlink:href="#plus"/></svg>
                <svg class="js-accordion-private-toggle-inactive card-toggle-icon icon-inline" style="display: none;"><use xlink:href="#minus"/></svg>
            </button>
        {% endif %}
    </div>
    <div class="{% if card_collapse %}js-accordion-private-content{% endif %} card-body {{ card_custom_body_class }}" {% if card_collapse %}style="display: none;"{% endif %}>
        {% block card_body %}{% endblock %}
    </div>
    {% if card_footer %}
        <div class="card-footer {{ card_custom_footer_class }}">
            {% block card_foot %}{% endblock %}
        </div>
    {% endif %}
</div>