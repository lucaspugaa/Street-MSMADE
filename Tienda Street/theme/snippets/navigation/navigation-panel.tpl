{#
  Navigation Panel
  Hamburger menu content: main nav list and secondary links.
#}
{% if primary_links %}
    {# Main navigation list - shown in modal body #}
    <div class="nav-list" data-store="navigation" data-component="menu">
        {% include 'snippets/navigation/navigation-list-hamburger.tpl' with { nav_banner_blocks: nav_block.blocks } %}
    </div>
    
    {# Secondary navigation - from navigation virtual block or global settings #}
    <div class="nav-secondary">
        {% set nav_block = null %}
        {% for block in section.blocks %}
            {% if block.type == 'header-navigation' %}
                {% set nav_block = block %}
            {% endif %}
        {% endfor %}

        {% set secondary_menu_id = nav_block ? nav_block.settings.menu : null %}
        {% set show_secondary = nav_block ? nav_block.settings.show_secondary_menu : true %}
        {% set mobile_secondary_links = secondary_menu_id ? menus[secondary_menu_id] | default([]) : [] %}

        {% if show_secondary and mobile_secondary_links | length > 0 %}
            <ul class="list-unstyled">
                {% for item in mobile_secondary_links %}
                    <li class="secondary-menu-item">
                        <a class="secondary-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
                    </li>
                {% endfor %}
            </ul>
        {% elseif not nav_block and settings.head_secondary_menu_show %}
            <ul class="list-unstyled">
                {% for item in menus[settings.head_secondary_menu] %}
                    <li class="secondary-menu-item">
                        <a class="secondary-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.name }}</a>
                    </li>
                {% endfor %}
            </ul>
        {% endif %}
    </div>

    {# Navigation bars configured with mobile_placement=menu are injected here by JS #}
    <div class="js-navbars-mobile-mount" style="display: none;"></div>
{% else %}
    {# Account and language - shown in modal footer #}
    <div class="nav-panel-account-row" data-store="account-links">
        <span class="nav-panel-account">
            <span class="nav-panel-account-links">
                <svg class="utility-icon icon-inline"><use xlink:href="#user"/></svg>
                {% set register_link = 'mandatory' not in store.customer_accounts %}
                {% if not customer %}
                    {{ 'general.my_account' | t | a_tag(store.customer_login_url, '', 'nav-panel-link') }}
                {% else %}
                    {% set customer_short_name = customer.name|split(' ')|slice(0, 1)|join %} 
                    {{ 'general.greeting' | t | replace('{1}', customer_short_name) | a_tag(store.customer_home_url, '', 'nav-panel-link nav-panel-link-spaced') }}
                    /
                    {{ 'general.logout' | t | a_tag(store.customer_logout_url, '', 'nav-panel-link') }}
                {% endif %}
            </span>
        </span>
        {% if languages | length > 1 %}
            <button class="js-modal-open-private header-utility" data-target="#modal-languages" aria-label="{{ 'general.languages_currencies' | t }}" data-modal-url="#modal-languages" data-component="languages-button">
                <span class="header-icon">
                    <svg class="utility-icon icon-inline"><use xlink:href="#world"/></svg>
                </span>
                <div class="utility-text-grid utility-text">
                    {% for language in languages if language.active %}
                        {{ language.country }}
                    {% endfor %}
                </div>
            </button>
        {% endif %}
    </div>
{% endif %}
