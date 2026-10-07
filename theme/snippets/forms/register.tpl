{# Register Form
  Customer registration form with account validation and reCAPTCHA.
#}

{% if account_validation == 'pending' %}

	{# Account Validation #}

	<div class="js-account-validation-pending alert form-alert-compact">
		<h5 class="form-validation-title">{{ 'forms.register.account_validation.pending_title' | t }}</h5>
		<div class="form-validation-text">{{ 'forms.register.account_validation.pending_sent' | t(customer_email) }}</div>
	</div>
	<div class="form-validation-help">
		{{ 'forms.register.account_validation.pending_help' | t }} <button type="button" class="js-resend-validation-link form-validation-link btn-link" data-customer-email="{{ customer_email }}">{{ 'forms.account_validation.resend_validation' | t }}</button>
	</div>

	<div class="js-resend-validation-success" style="display: none;">
		{% include 'snippets/forms/alert.tpl' with {
			type: 'success',
			class: 'form-alert-compact',
			message: ('forms.account_validation.sent_success' | t)
		} %}
	</div>

	<div class="js-resend-validation-error" style="display: none;">
		{% include 'snippets/forms/alert.tpl' with {
			type: 'danger',
			class: 'form-alert-compact',
			message: ('forms.account_validation.sent_fail' | t)
		} %}
	</div>

{% else %}

	{# Register form #}

	<form id="register-form" action="" method="post" class="js-form form" data-store="account-register">

		{{ component('nubesdk-slot', { type: "before_register_form_fields" }) }}

		{# Name #}

		<div class="form-group">
			<label class="form-label" for="name">{{ 'forms.name.label' | t }}</label>
			<input type="text" id="name" name="name" value="{{ result.name }}" autocorrect="off" autocapitalize="off" class="js-account-input form-control" placeholder="{{ 'forms.name.placeholder' | t }}">
			{% if result.errors.name %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.name' | t }}</div>
			{% endif %}
		</div>

		{# Email #}

		<div class="form-group">
			<label class="form-label" for="email">{{ 'forms.email.label' | t }}</label>
			<input type="email" id="email" name="email" value="{{ result.email }}" autocorrect="off" autocapitalize="off" class="js-account-input form-control" placeholder="{{ 'forms.email.placeholder' | t }}">
			{% if result.errors.email == 'exists' %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.email_used' | t }}</div>
			{% elseif result.errors.email %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.email' | t }}</div>
			{% endif %}
		</div>

		{# Phone #}

		<div class="form-group">
			<label class="form-label" for="phone">{{ 'forms.phone.label' | t }}</label>
			<input type="tel" id="phone" name="phone" value="{{ result.phone }}" autocorrect="off" autocapitalize="off" class="js-account-input form-control" placeholder="{{ 'forms.phone.placeholder' | t }}">
		</div>

		{# Password #}

		<div class="form-group">
			<label class="form-label" for="password">{{ 'forms.password.label' | t }}</label>
			<input type="password" id="password" name="password" autocorrect="off" autocapitalize="off" autocomplete="off" class="js-account-input js-password-input form-control" required placeholder="{{ 'forms.password.placeholder' | t }}">

			<a aria-label="{{ 'forms.password.aria_label' | t }}" class="js-password-toggle password-toggle btn">
				<span class="js-password-visible password-toggle-show" style="display: none;">
					<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-show"/></svg>
				</span>
				<span class="js-password-hidden password-toggle-hide">
					<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-hide"/></svg>
				</span>
			</a>

			{% if result.errors.password == 'required' %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.password' | t }}</div>
			{% endif %}
		</div>

		{# Password confirm #}

		<div class="form-group">
			<label class="form-label" for="password_confirmation">{{ 'forms.password_confirm_label' | t }}</label>
			<input type="password" id="password_confirmation" name="password_confirmation" autocorrect="off" autocapitalize="off" autocomplete="off" class="js-account-input js-password-input form-control" required placeholder="{{ 'forms.password.placeholder' | t }}">

			<a aria-label="{{ 'forms.password.aria_label' | t }}" class="js-password-toggle password-toggle btn">
				<span class="js-password-visible password-toggle-show" style="display: none;">
					<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-show"/></svg>
				</span>
				<span class="js-password-hidden password-toggle-hide">
					<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-hide"/></svg>
				</span>
			</a>

			{% if result.errors.password == 'required' %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.password' | t }}</div>
			{% endif %}
			{% if result.errors.password == 'confirmation' %}
				<div class="notification-danger notification-left">{{ 'forms.register.error.password_confirm' | t }}</div>
			{% endif %}
		</div>

		{{ component('nubesdk-slot', { type: "after_register_form_fields" }) }}

		{# Google reCAPTCHA #}

		<div class="g-recaptcha" data-sitekey="{{recaptchaSiteKey}}" data-callback="recaptchaCallback"></div>

		{{ component('nubesdk-slot', { type: "before_register_form_submit" }) }}

		<button class="js-recaptcha-button btn btn-primary btn-big btn-block" type="submit" value="{{ 'forms.register.submit' | t }}" name="" disabled>
			{{ 'forms.register.submit' | t }}
			<span class="js-form-spinner form-spinner" style="display:none;">
				{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
			</span>
		</button>

		{{ component('nubesdk-slot', { type: "after_register_form_submit" }) }}

		<div class="form-login-help">
			{{ 'forms.register.register_help' | t }}
			<a href="{{ store.customer_login_url }}" class="form-login-help-link btn-link">{{ 'forms.register.register_help_link' | t }}</a>
		</div>
	</form>

	{# Google reCAPTCHA on register page #}

	{% include 'snippets/forms/recaptcha-script.tpl' %}
{% endif %}
