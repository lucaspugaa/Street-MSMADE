{#
  Login Form
  Customer login form with validation messages.
#}
{# Account Validation #}

{% if account_validation == 'success' %}
	{% include 'snippets/forms/alert.tpl' with {
		type: 'success',
		class: 'js-account-validation-success form-alert-spaced',
		message: ('forms.login.account_validation.success' | t)
	} %}
{% elseif account_validation == 'expired' %}
	{% include 'snippets/forms/alert.tpl' with {
		type: 'danger',
		class: 'js-account-validation-expired form-alert-compact',
		message: ('forms.login.account_validation.expired' | t)
	} %}
	<div class="form-validation-help">
		<button type="button" class="js-resend-validation-link form-validation-link btn-link" data-customer-email="{{ customer_email }}">{{ 'forms.account_validation.resend_validation' | t }}</button>
	</div>
{% elseif account_validation == 'pending' %}
	<div class="js-account-validation-pending alert alert-danger form-alert-compact">{{ 'forms.login.account_validation.pending' | t(customer_email) }}</div>

	<div class="form-validation-help">
		{{ 'forms.login.account_validation.pending_question' | t }}
		<button type="button" class="js-resend-validation-link form-validation-link btn-link" data-customer-email="{{ customer_email }}">{{ 'forms.account_validation.resend_validation' | t }}</button>
	</div>
{% endif %}

<div class="js-resend-validation-success form-alert-spaced" style="display: none;">
	{% include 'snippets/forms/alert.tpl' with {
		type: 'success',
		message: ('forms.account_validation.sent_success' | t)
	} %}
</div>
<div class="js-resend-validation-error form-alert-spaced" style="display: none;">
	{% include 'snippets/forms/alert.tpl' with {
		type: 'danger',
		message: ('forms.account_validation.sent_fail' | t)
	} %}
</div>

<div class="js-too-many-attempts alert alert-danger form-alert-spaced" style="display:none">
	{{ 'forms.account_validation.sent_timeout' | t }}
	<span class="js-too-many-attempts-countdown"></span>
</div>

{# Login form #}

<form id="login-form" action="" method="post" class="js-form form" data-store="account-login">

	{# Email #}

	<div class="form-group">
		<label class="form-label" for="email">{{ 'forms.email.label' | t }}</label>
		<input type="email" name="email" value="{{ result.email }}" autocorrect="off" autocapitalize="off" class="js-account-input form-control" required placeholder="{{ 'forms.email.placeholder' | t }}">
	</div>

	{# Password #}

	<div class="form-group">
		<label class="form-label" for="password">{{ 'forms.password.label' | t }}</label>
		<input type="password" name="password" autocorrect="off" autocapitalize="off" autocomplete="off" class="js-account-input js-password-input form-control" required placeholder="{{ 'forms.password.placeholder' | t }}">

		<a aria-label="{{ 'forms.password.aria_label' | t }}" class="js-password-toggle password-toggle btn">
			<span class="js-password-visible password-toggle-show" style="display: none;">
				<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-show"/></svg>
			</span>
			<span class="js-password-hidden password-toggle-hide">
				<svg class="password-toggle-icon icon-inline"><use xlink:href="#password-hide"/></svg>
			</span>
		</a>

		<div class="login-password-help">
			<a href="{{ store.customer_reset_password_url }}" class="login-password-help-link btn-link">{{ 'forms.password_help' | t }}</a>
		</div>
	</div>
	
	<button class="btn btn-primary btn-big btn-block" type="submit" value="{{ 'forms.login.submit' | t }}" name="">
		{{ 'forms.login.submit' | t }}
		<span class="js-form-spinner form-spinner" style="display:none;">
			{% include 'snippets/icon.tpl' with { name: 'spinner', size: 16, class: 'icon-loading' } %}
		</span>
	</button>

	{% if 'mandatory' not in store.customer_accounts %}
		<div class="form-login-help">{{ 'forms.login.login_help' | t }}
			<a href="{{ store.customer_register_url }}" class="form-login-help-link btn-link">{{ 'forms.login.login_help_link' | t }}</a>
		</div>
	{% endif %}

	{% if result.invalid %}
		{% include 'snippets/forms/alert.tpl' with {
			type: 'danger',
			class: 'js-login-general-error',
			message: ('forms.login.error_general' | t)
		} %}
	{% endif %}
</form>
