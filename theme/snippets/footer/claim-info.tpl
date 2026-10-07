{% if store.country == 'AR' %}
	<div class="claim-link">
		<span class="claim-text">{{ 'claim_info.consumer_defense' | t }}</span>
		<a class="claim-link-action btn-link" href="https://www.argentina.gob.ar/produccion/defensadelconsumidor/formulario" target="_blank" rel="noopener noreferrer" data-component="consumer-defense">{{ 'claim_info.consumer_defense_link' | t }}</a>

		{% set order_cancellation_url = status_page_url_regret ? '?order_cancellation=true' : '?order_cancellation_without_id=true' %}
		<span class="">/</span>
		<a class="claim-link-action btn-link" href="{{ store.contact_url }}{{ order_cancellation_url }}" data-component="order-cancellation">{{ 'claim_info.order_cancellation_link' | t }}</a>
	</div>
{% endif %}
