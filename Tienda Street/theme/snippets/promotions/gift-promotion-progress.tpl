{#
	Gift Promotion Progress Bar
	Pre-renders every message variant (title / description / caption) for both
	modes;
	JS only updates dynamic spans (amount, gift names, gifts-won count) and
	displays the correct messages based on the current status.
#}
{% set gift_promotion_progress = store.get_gift_promotion_progress() %}
{% if gift_promotion_progress %}
	<div class="{{ container_class }}">
		{% set mode = gift_promotion_progress.mode %}
		{% set reached = gift_promotion_progress.reached_tier_count %}
		{% set total = gift_promotion_progress.total_tier_count %}
		{% set percentage = gift_promotion_progress.progress_percentage %}
		{% set gifts_won = gift_promotion_progress.gifts_won_count %}
		{% set amount_to_next = gift_promotion_progress.amount_to_next_tier %}
		{% set amount_to_next_cents = amount_to_next is not null ? (amount_to_next * 100) | round : 0 %}
		{% set next_gift = gift_promotion_progress.next_tier_gift %}
		{% set state = reached == 0 ? 'no-gifts' : (reached >= total ? 'all-gifts' : 'intermediate') %}
		{% set amount_span = '<span class="js-gift-promotion-progress-amount">' ~ (amount_to_next_cents | money) ~ '</span>' %}
		{% set next_name_span = '<span class="js-gift-promotion-progress-next-name">' ~ (next_gift ? next_gift.product_name|e : '') ~ '</span>' %}
		{% set gifts_won_span = '<span class="js-gift-promotion-progress-gifts-won">' ~ gifts_won ~ '</span>' %}

		<div
			class="js-gift-promotion-progress js-visible-on-cart-filled gift-promotion-progress box"
			data-gift-progress
			data-state="{{ state }}"
			data-mode="{{ mode }}"
			data-transition="none"
			data-reached-tier-count="{{ reached }}"
			data-progress-percentage="{{ percentage }}"
			{% if cart.items_count == 0 %}style="display: none;"{% endif %}
		>
			{% embed "snippets/progress-bar.tpl" with {
				icon_name: 'gift',
				initial_percentage: percentage,
				title_class: 'gift-promotion-progress-title-container',
				amount_span: amount_span,
				next_name_span: next_name_span,
				gifts_won_span: gifts_won_span,
			} only %}
				{% block title_content %}
					{# Accumulation variants #}
					<span class="js-gift-progress-title-accumulation-no-gifts gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_static_no_gifts' | t | replace('{1}', amount_span) | raw -}}
					</span>
					<span class="js-gift-progress-title-accumulation-with-next gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_static_with_next' | t | replace('{1}', amount_span) | replace('{2}', next_name_span) | raw -}}
					</span>
					<span class="js-gift-progress-title-accumulation-all-gifts gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_static_all_gifts' | t -}}
					</span>
					<span class="js-gift-progress-title-accumulation-up gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_up_many' | t | replace('{1}', gifts_won_span) | raw -}}
					</span>
					<span class="js-gift-progress-title-accumulation-down-one gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_down_one' | t -}}
					</span>
					<span class="js-gift-progress-title-accumulation-down-many gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.title_down_many' | t -}}
					</span>

					{# Replacement variants #}
					<span class="js-gift-progress-title-replacement-no-gifts gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_static_no_gifts' | t | replace('{1}', amount_span) | raw -}}
					</span>
					<span class="js-gift-progress-title-replacement-stay gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_stay' | t | replace('{1}', amount_span) | raw -}}
					</span>
					<span class="js-gift-progress-title-replacement-up gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_up' | t -}}
					</span>
					<span class="js-gift-progress-title-replacement-all-gifts gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_all_gifts' | t -}}
					</span>
					<span class="js-gift-progress-title-replacement-down-one gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_down_one' | t -}}
					</span>
					<span class="js-gift-progress-title-replacement-down-many gift-promotion-progress-title" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.title_down_many' | t | replace('{1}', amount_span) | raw -}}
					</span>
				{% endblock %}
				{% block subtitle_content %}
					{# Accumulation #}
					<span class="js-gift-progress-desc-accumulation-with-next gift-promotion-progress-description" style="display: none;">
						{{- 'cart.gift_promotion_progress.accumulation_mode.description_with_next' | t | replace('{1}', amount_span) | replace('{2}', next_name_span) | raw -}}
					</span>

					{# Replacement #}
					<span class="js-gift-progress-desc-replacement-stay gift-promotion-progress-description" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.description_stay' | t | replace('{1}', next_name_span) | raw -}}
					</span>
					<span class="js-gift-progress-desc-replacement-up gift-promotion-progress-description" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.description_up' | t | replace('{1}', amount_span) | replace('{2}', next_name_span) | raw -}}
					</span>
					<span class="js-gift-progress-desc-replacement-down-one gift-promotion-progress-description" style="display: none;">
						{{- 'cart.gift_promotion_progress.replacement_mode.description_down_one' | t | replace('{1}', amount_span) | replace('{2}', next_name_span) | raw -}}
					</span>
				{% endblock %}
			{% endembed %}
		</div>
	</div>
{% endif %}
