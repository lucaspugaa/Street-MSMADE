{% if not store.hasContactFormsRecaptcha() %}
	{{ '//www.google.com/recaptcha/api.js' | script_tag(true) }}
{% endif %}
<script type="text/javascript">
	var recaptchaCallback = function() {
		jQueryNuvem('.js-recaptcha-button').prop('disabled', false);
	};
</script>
