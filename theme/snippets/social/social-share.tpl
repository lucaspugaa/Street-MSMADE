{#
  Social Share
  Product share buttons for WhatsApp, Facebook, Twitter and Pinterest.
#}
<div class="social-share">
	<a href="whatsapp://send?text={{ product.social_url }}"
		class="social-share-link d-md-none"
		target="_blank"
		rel="noopener noreferrer"
		data-network="whatsapp"
		title="{{ 'social.share_whatsapp' | t }}"
		aria-label="{{ 'social.share_whatsapp' | t }}">
		<svg class="icon-inline"><use xlink:href="#whatsapp"/></svg>
	</a>
	<a href="https://www.facebook.com/sharer/sharer.php?u={{ product.social_url }}"
		class="social-share-link"
		target="_blank"
		rel="noopener noreferrer"
		data-network="facebook"
		title="{{ 'social.share_facebook' | t }}"
		aria-label="{{ 'social.share_facebook' | t }}">
		<svg class="icon-inline"><use xlink:href="#facebook"/></svg>
	</a>
	<a href="https://twitter.com/share?url={{ product.social_url }}"
		class="social-share-link"
		target="_blank"
		rel="noopener noreferrer"
		data-network="twitter"
		title="{{ 'social.share_twitter' | t }}"
		aria-label="{{ 'social.share_twitter' | t }}">
		<svg class="icon-inline"><use xlink:href="#twitter"/></svg>
	</a>
	<a href="#"
		class="js-pinterest-share social-share-link"
		target="_blank"
		rel="noopener noreferrer"
		data-network="pinterest"
		title="{{ 'social.share_pinterest' | t }}"
		aria-label="{{ 'social.share_pinterest' | t }}">
		<svg class="icon-inline"><use xlink:href="#pinterest"/></svg>
	</a>
	<div class="js-pinterest-hidden" style="display: none;" data-network="pinterest">
		{{ product.social_url | pin_it('https:' ~ product.featured_image | product_image_url('large')) }}
	</div>
</div>
