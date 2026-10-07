{% if store.allows_checkout_styling %}

{#/*============================================================================
checkout.scss.tpl

    -This file contains all the theme styles related to the checkout based on settings defined by user from config/settings.txt
    -Rest of styling can be found in:
        -static/css/style-async.css --> For non critical styles witch will be loaded asynchronously
        -static/css/style-critical.css --> For critical CSS rendered inline before the rest of the site

==============================================================================*/#}

{#/*============================================================================
  Global
==============================================================================*/#}

:root {

  {#/*============================================================================
    # Checkout tokens
  ==============================================================================*/#}

  {#### Colors settings #}

  {# Main colors #}

  {% set main_background = settings.checkout_main_background | default(settings.background_color) %}
  {% set main_foreground = settings.checkout_main_foreground | default(settings.text_color) %}
  {% set accent_color = settings.checkout_accent_color | default(settings.accent_color) %}

  {% set button_background = settings.checkout_button_background | default(settings.button_primary_background_color) %}
  {% set button_foreground = settings.checkout_button_foreground | default(settings.button_primary_foreground_color) %}
  {% set button_style = settings.button_primary_style | default('filled') %}

  {% set label_background = settings.label_background_color %}
  {% set label_foreground = settings.label_foreground_color %}
  {% set label_border_radius = settings.label_border_radius | default(4) %}
  {% set label_style = settings.label_style | default('filled') %}

  {% set header_background = settings.checkout_header_background | default(settings.background_color) %}
  {% set header_foreground = settings.checkout_header_foreground | default(settings.text_color) %}

  {#### Color tokens #}

  {# Auxiliar opacity hex levels #}
  {% set opacity_05 = '0D' %}
  {% set opacity_10 = '1A' %}
  {% set opacity_15 = '26' %}
  {% set opacity_20 = '33' %}
  {% set opacity_30 = '4D' %}
  {% set opacity_50 = '80' %}
  {% set opacity_60 = '99' %}
  {% set opacity_80 = 'CC' %}

  {# Accent color #}
  --accent-color: {{ accent_color }};
  --accent-color-opacity-05: {{ accent_color }}{{ opacity_05 }};
  --accent-color-opacity-10: {{ accent_color }}{{ opacity_10 }};
  --accent-color-opacity-15: {{ accent_color }}{{ opacity_15 }};
  --accent-color-opacity-20: {{ accent_color }}{{ opacity_20 }};
  --accent-color-opacity-30: {{ accent_color }}{{ opacity_30 }};
  --accent-color-opacity-50: {{ accent_color }}{{ opacity_50 }};
  --accent-color-opacity-60: {{ accent_color }}{{ opacity_60 }};
  --accent-color-opacity-80: {{ accent_color }}{{ opacity_80 }};

  {# Foreground color #}
  --main-foreground: {{ main_foreground }};
  --main-foreground-opacity-05: {{ main_foreground }}{{ opacity_05 }};
  --main-foreground-opacity-10: {{ main_foreground }}{{ opacity_10 }};
  --main-foreground-opacity-15: {{ main_foreground }}{{ opacity_15 }};
  --main-foreground-opacity-20: {{ main_foreground }}{{ opacity_20 }};
  --main-foreground-opacity-30: {{ main_foreground }}{{ opacity_30 }};
  --main-foreground-opacity-50: {{ main_foreground }}{{ opacity_50 }};
  --main-foreground-opacity-60: {{ main_foreground }}{{ opacity_60 }};
  --main-foreground-opacity-80: {{ main_foreground }}{{ opacity_80 }};

  {# Background color #}
  --main-background: {{ main_background }};
  --main-background-opacity-05: {{ main_background }}{{ opacity_05 }};
  --main-background-opacity-10: {{ main_background }}{{ opacity_10 }};
  --main-background-opacity-15: {{ main_background }}{{ opacity_15 }};
  --main-background-opacity-20: {{ main_background }}{{ opacity_20 }};
  --main-background-opacity-30: {{ main_background }}{{ opacity_30 }};
  --main-background-opacity-50: {{ main_background }}{{ opacity_50 }};
  --main-background-opacity-60: {{ main_background }}{{ opacity_60 }};
  --main-background-opacity-80: {{ main_background }}{{ opacity_80 }};

  {#### Component tokens #}

  {# General #}
  --border-radius: 4px;
  --box-border-radius: var(--border-radius);
  --border-color: var(--main-foreground-opacity-50);
  --box-border-color: var(--main-foreground-opacity-10);

  {# Buttons #}
  --button-foreground: {{ button_foreground }};
  --button-background: {{ button_background }};
  --button-border-color: {{ button_style == 'outline' ? 'var(--button-foreground)' : 'var(--button-background)' }};
  --button-border-radius: var(--border-radius);

  {# Labels #}
  --label-foreground: {{ label_foreground }};
  --label-background: {{ label_background }};

  --label-primary-background: var(--label-background);
  --label-primary-border-color: {{ label_style == 'outline' ? 'var(--label-foreground)' : 'var(--label-background)' }};
  --label-primary-foreground: var(--label-foreground);
  --label-primary-border-radius: {{ label_border_radius }}px;

  {# Header #}
  --header-foreground: {{ header_foreground }};
  --header-background: {{ header_background }};
  --header-logo-max-width: 100%;
  --header-logo-max-height: 40px;

  {# Footer #}
  --footer-foreground: {{ main_foreground }};
  --footer-background: {{ main_background }};

  {#### Typography #}

  {# Headings #}
  --heading-font: {{ settings.font_headings | default('Lexend') | raw }};
  --heading-font-weight: 400;
  --heading-text-transform: uppercase;
  --heading-letter-spacing: normal;

  {# Header #}
  --header-logo-font: var(--heading-font);
  --header-logo-font-size: 20px;
  --header-logo-font-weight: 700;
  --header-logo-text-transform: none;
  --header-logo-letter-spacing: normal;

  {# Body #}
  --body-font: {{ settings.font_rest | default('Lexend') | raw }};

  {#### Misc tokens #}

  {# Font sizes #}
  --font-base: 1rem;
  --font-medium: 0.875rem;
  --font-small: 0.75rem;
  --font-smallest: 0.625rem;

  {# Danger #}
  --danger: #c13a3a;
}

{# /* // Mixins */ #}

@mixin prefix($property, $value, $prefixes: ()) {
    @each $prefix in $prefixes {
        #{'-' + $prefix + '-' + $property}: $value;
    }
    #{$property}: $value;
}

{#/*============================================================================
  React
==============================================================================*/#}


$xs: 0;
$sm: 576px;
$md: 768px;
$lg: 992px;
$xl: 1200px;

body {
  font-family: var(--body-font);
  color: var(--main-foreground);
  background-color: var(--main-background);
  font-size: var(--font-medium);
}
a {
  color: var(--main-foreground);
  text-decoration: none;
  &:hover, &:focus {
    color: var(--main-foreground-opacity-60);

    svg {
      fill: var(--main-foreground);
    }
  }

  svg {
    fill: var(--accent-color);
  }
}

{# /* // Text */ #}

.title {
  color: var(--main-foreground);
}

.heading-small {
  font-size: var(--font-medium);
  font-weight: normal;
}

.text-small {
  font-size: var(--font-small);
}

{# /* // Header */ #}

.header {
  background-color: var(--main-background);
  border-color: var(--accent-color);
}

.security-seal {
  color: var(--header-foreground);
}

{# /* // Headbar */ #}

.headbar {
  padding: 0;
  background: var(--header-background);
  box-shadow: none;

  .container {
    max-width: 100%;
    width: 100%;
    padding: 0 15px;
    border: 0;

    .row {
      -ms-flex-align: center;
      align-items: center;

      {% if settings.logo_position_desktop == 'center' %}
        -ms-flex-pack: center!important;
        justify-content: center!important;

        > .text-left {
          text-align: center !important;
          -ms-flex: 0 0 50%;
          flex: 0 0 50%;
          max-width: 50%;
          margin-left: 25%;
        }
      {% endif %}
    }
  }
}

.headbar-logo-img {
  max-width: 100%;
  max-height: 40px;
}

.headbar-logo-text {
  float: none;
  color: var(--header-foreground);
  font-weight: 700;

  &:hover {
    color: var(--header-foreground);
    opacity: .8;
  }

  &:focus {
    color: var(--main-background);
  }
}

.headbar-continue {
  margin: 0 !important;
  font-weight: 400;
  color: var(--header-foreground);
  &:hover,
  &:focus {
    color: var(--header-foreground);
    opacity: .8;

    .headbar-continue-icon {
      fill: var(--header-foreground);
    }
  }
  &-icon {
    margin-left: 5px;
    fill: var(--header-foreground);
  }
}

{# /* // Form */ #}

.form-group {
  margin-bottom: 15px;
}
.form-control {
  background: var(--main-background);
  border-color: var(--border-color);
  color: var(--main-foreground);
  font-family: var(--body-font);
  border-radius: var(--border-radius);

  &:focus {
    border-color: var(--main-foreground);
    outline: none;
  }
}
.form-group.form-group-error .form-control {
  border-radius: var(--border-radius);
}
.form-options-content {
  font-size: var(--font-small);
  line-height: 16px;
  color: var(--main-foreground-opacity-60);
  border: 0;
}
.form-group input[type="radio"] + .form-options-content .unchecked {
  fill: var(--main-foreground-opacity-10);
}
.form-group input[type="radio"] + .form-options-content .checked {
  fill: var(--accent-color);
}
.form-group input[type="radio"]:checked + .form-options-content {
  border: 1px solid var(--accent-color);
  border-color: var(--main-foreground-opacity-10);

  + .form-options-accordion {
    border-color: var(--main-foreground-opacity-10);
  }

  .checked {
    fill: var(--accent-color);
  }
}
.form-group input[type="checkbox"]:checked + .form-options-content .checked {
  fill: var(--main-foreground);
}
.form-group input[disabled] + .form-options-content {
  border-color: var(--main-foreground-opacity-10) !important;

  .form-options-label {
    color: var(--main-foreground) !important;
  }
  .checked {
    fill: var(--main-foreground) !important;
  }
}
.form-group input[type="checkbox"] + .form-options-content .form-group-icon {
  border-radius: 2px;
  overflow: hidden;
}
.form-group input[type="checkbox"] + .form-options-content svg {
  width: 13px;
  height: 13px;
}
.form-group input[type="checkbox"] + .form-options-content .unchecked {
  width: 13px;
  fill: var(--main-foreground);
}

{# /* // Input */ #}

.has-float-label>span,
.has-float-label label {
  padding: 1px 0 0 7px;
  font-weight: 400;
}

.has-float-label .form-control-help {
  z-index: 1;
}

.input-label {
  color: var(--main-foreground);
}

.select-icon {
  fill: var(--main-foreground);
  svg {
    width: 10px;
  }
}

{# /* // Buttons */ #}

.btn {
  border-radius: var(--border-radius);
}
.btn-primary {
  padding: 15px;
  color: var(--button-foreground);
  background: var(--button-background);
  border-radius: var(--border-radius);
  font-size: var(--font-medium);
  line-height: 18px;
  text-transform: none !important;
  {% if button_style == 'outline' %}
  border: 1px solid var(--button-border-color);
  {% endif %}

  &:hover,
  &:focus,
  &:active {
    color: var(--button-foreground);
    background: var(--button-background);
    opacity: 0.9;
  }
}
.btn-secondary {
  min-width: auto;
  padding: 0;
  color: var(--main-foreground);
  font-size: var(--font-small);
  line-height: 10px;
  border: 0;
  border-radius: var(--border-radius);
  background: var(--main-background);
  text-decoration: underline;

  &:hover,
  &:focus,
  &:active,
  &:active:focus {
    background: var(--main-background);
    color: var(--main-foreground);
    opacity: .8;

    .btn-icon-right {
      fill: var(--button-background);
    }
  }
  .btn-icon-right {
    fill: var(--accent-color);
  }
}
.btn-transparent {
  color: var(--main-foreground);

  &:hover {
    color: var(--main-foreground);
    opacity: .6;

    .btn-icon-right {
      fill: var(--main-foreground);
    }
  }

  .btn-icon-right {
    width: 10px;
    fill: var(--main-foreground);
  }
}

.btn-link {
  color: var(--main-foreground);
  font-size: var(--font-small);
  font-weight: normal;
  text-transform: initial;
  &:hover {
    color: var(--main-foreground-opacity-60);

    svg {
      fill: var(--main-foreground-opacity-60);
    }
  }
}

.btn:active {
  box-shadow: none;
}

.btn-picker {
  border-color: var(--border-color);
  border-radius: var(--border-radius);
}

.login-info {
  margin: 10px 0 0;
  font-size: var(--font-small);
  text-align: left;
}

{# /* // Breadcrumb */ #}

.breadcrumb {
  max-width: 100%;

  li .breadcrumb-step {
    margin: 0;
    font-size: var(--font-small);
    color: var(--main-foreground-opacity-60);
    background: none;
    text-transform: none;

    &.active {
      color: var(--main-foreground);
      background: none;

      &:before,
      &:after {
        position: relative;
        margin: 0 5px;
        border: 0;
        content: ">";
        opacity: .6;
      }
    }

    &.visited {
      color: var(--main-foreground-opacity-60);
      background: none;
    }
  }
  li:first-child .breadcrumb-step,
  li:last-child .breadcrumb-step {
    padding: 0;
  }
}

{# /* // Accordion */ #}

.accordion {
  color: var(--main-foreground);
  background-color: var(--main-background);
  border-radius: var(--border-radius);
  box-shadow: 0 1px 3px -1px var(--main-foreground-opacity-10);
  border-color: var(--main-foreground-opacity-15);
}

.accordion-section-header-icon {
  fill: var(--main-foreground);
}

.accordion-rotate-icon {
  fill: var(--main-foreground);
}

{# /* // Summary */ #}

.summary {
  top: 0;
}
.summary-img {
  &-thumb {
    left: 0;
    border-radius: 0;
    background: none;
  }
  img {
    max-height: fit-content;
  }
}

.mobile-discount-coupon_btn {
  border-radius: var(--border-radius);
  border-color: var(--main-foreground-opacity-10);
  color: var(--main-foreground-opacity-80);

  .icon {
    color: var(--main-foreground-opacity-80);
  }
}

.panel.summary-details {
  background: var(--main-background);
  overflow: hidden;
}
.summary-container {
  padding: 10px 15px;
  background: var(--main-background);
  border-top: 1px solid var(--main-foreground-opacity-20);
  border-bottom: 1px solid var(--main-foreground-opacity-20);
  box-shadow: none;
}
.summary-total {
  font-size: var(--font-base);
  font-weight: 700;
  color: var(--main-foreground);
  background: none;
}

.summary-arrow-rounded {
  width: auto;
  background: none;
  .summary-arrow-icon {
    fill: var(--main-foreground);
  }
}

.summary-title {
  color: var(--main-foreground);
  font-size: var(--font-small);
  text-decoration: underline;
}

.summary-coupon {
  padding: 0;
  &+.breadcrumb {
    margin: 0;
  }
}

{# /* // Radio */ #}

.radio-group {

  &.radio-group-accordion {
    border: none;
    overflow: hidden;

    .radio {
      padding: 10px 0;
      border: 0;
      &.active {
        .description {
          color: var(--main-background);
        }
        .payment-item-discount {
          color: var(--main-background);
        }
      }
      .description {
        width: calc(100% - 35px);
        margin-left: 35px;
        font-weight: 400;
      }
    }
  }
}

.radio input:checked + .selector:before {
  background-image: none;
  border-color: var(--main-foreground);
  border-radius: var(--border-radius);
}
.radio input:disabled:checked + .selector:before {
  background-image: radial-gradient(circle, rgba(0, 0, 0, 0.5) 0%, rgba(0, 0, 0, 0.5) 50%, transparent 50%, transparent 100%);
}
.radio input:checked + .selector:after {
  position: absolute;
  left: 4px;
  bottom: 4px;
  width: 7px;
  height: 7px;
  background: var(--main-foreground);
  content: '';
}
.radio .selector {
  position: relative;

  &:before {
    width: 15px;
    height: 15px;
    margin: 1px 15px 0 0;
    background-color: var(--main-background);
    border-color: var(--main-foreground);
    border-radius: var(--border-radius);
  }
}

.radio-content {
  margin-bottom: 20px;
  padding: 10px 0 0;
  background: var(--main-background);
  border: 0;
  box-shadow: none;

  .text-center {
    text-align: left !important;
  }
  .p-all {
    padding-top: 0 !important;
  }
}

.shipping-option {
  position: relative;
  padding: 15px;
  background: var(--main-foreground-opacity-05);
  border-radius: 0;
  border: 0;

  &.active {
    border: none;
  }

  .selector {
    position: absolute;
    top: 5px;
    left: 15px;
    width: 15px;
    margin: 0;
    text-align: center;
    &:before {
      margin: 10px 0 0 0;
    }
  }
}

{# /* // Panel */ #}

.panel {
  padding: 0;
  color: var(--main-foreground);
  background-color: var(--main-background);
  box-shadow: none;
  border: 0;
  border-radius: 0;
  &.panel-with-header {
    padding-top: 5px;
    p {
      margin-top: 0;
    }
  }
  &.text-center {
    text-align: left !important;
  }
  .shipping-address-container .panel-subheader:before {
    display: none;
  }
}
.panel-header {
  margin: 0 !important;
  font-size: var(--font-base);
  color: var(--main-foreground);
  text-align: left;
  border: 0;
  text-shadow: none;
}
.panel-header-tooltip {
  padding: 0 5px;
}
.panel-header-sticky {
  background-color: var(--main-background);
}
.panel-header-button {
  position: absolute;
  top: 13px;
  right: 0;
  z-index: 2;
  width: auto;
}
.panel-subheader {
  margin: 5px 0 10px 0;
  font-size: var(--font-small);
  font-weight: normal;
}
.panel-footer {
  background: var(--main-foreground-opacity-05);
  &-wa {
    border-color: var(--main-foreground-opacity-05);
  }
}
.panel-footer-form {
  input {
    border-color: var(--main-foreground);
  }
  .input-group-addon {
    background: var(--main-background);
    border-color: var(--main-foreground);
  }
  .disabled {
    background: var(--main-foreground-opacity-10) !important;
  }
}

{# /* // Table */ #}

.table.table-scrollable td {
    padding: 10px 15px;
}

.table-footer {
  font-size: var(--font-base);
  color: var(--main-foreground);
  border: 0;
}

.table-subtotal {
  margin: 0;
  padding: 10px 0;
  border: 0;
  td {
    padding: 5px 15px;
  }
  .text-semi-bold {
    font-weight: 400;
  }
}

.table .table-discount-coupon,
.table .table-discount-promotion {
  color: var(--accent-color);
  border: 0;
}

{# /* // Shipping Options */ #}

.shipping-options {
  color: var(--main-foreground-opacity-80);

  .radio-group {
    border-radius: var(--border-radius);
    box-shadow: 0 1px 3px -1px var(--main-foreground-opacity-10);
    overflow: hidden;
  }

  .btn {
    margin: 0;
    background: var(--main-background);
  }

}

.new-shipping-flow .shipping-options .radio-group {
  box-shadow: none;
  overflow: inherit;
}

.new-shipping-flow .shipping-options .btn {
  padding-top: 15px;
  border: 0;
}

.shipping-method-item {
  margin-left: 25px;
  > span {
    width: 100%;
  }
}

.shipping-method-item-desc,
.shipping-method-item-name {
  max-width: 70%;
  color: var(--main-foreground);
  font-size: var(--font-small);
  font-weight: normal;
}

.shipping-method-item-desc {
  opacity: .6 !important;
}

.shipping-method-item-price {
  float: right;
  font-weight: normal;
  color: var(--main-foreground);
  text-align: right;
}

.price-striked {
  display: block;
  margin: 5px 0 0 !important;
  font-size: var(--font-smallest);
  color: var(--main-foreground-opacity-60);
}

{# /* // Discount Coupon */ #}

.box-discount-coupon {
  margin-top: -1px;
  button {
    color: var(--main-foreground);
    background: none;

    &:hover {
      opacity: .6;
      background: none;
    }
    svg {
      fill: var(--main-foreground);
    }
  }
}
.box-discount-coupon-applied {
  padding: 10px 15px;
  color: var(--main-foreground);
  background: none;
  border-radius: 0;
  font-size: 8px;
  line-height: 20px;
  letter-spacing: 1px;
  text-transform: uppercase;

  .btn-link {
    padding-top: 3px;
    color: var(--main-foreground);
    &:hover {
      color: var(--main-foreground-opacity-60);
    }
  }
  .coupon-icon {
    display: none;
  }
}


{# /* // Support */ #}

.support {
  margin: 0;
  padding: 20px 0;
  svg {
    width: 14px;
    vertical-align: middle;
    fill: var(--main-foreground);
  }
  .btn-secondary {
    margin: 0 0 15px 0 !important;
  }
}

{# /* // User Detail */ #}

.user-detail {
  margin: 0 !important;
  padding: 15px 15px 15px 0;
  background: var(--main-background);
  border-radius: var(--border-radius);
  &-icon {
    width: 40px;
    svg {
      left: initial;
      width: 15px;
      height: 16px;
      fill: var(--main-foreground);
    }
  }
  &-content {
    width: calc(100% - 50px);
    .text-semi-bold {
      font-size: var(--font-smallest);
      font-weight: 400;
      letter-spacing: 1px;
    }
  }
}


{# /* // History */ #}

.history-item-done .history-item-title {
  color: var(--accent-color);
}
.history-item-failure .history-item-title {
  color: var(--danger);
}
.history-item-progress-icon svg {
  width: 20px;
  fill: var(--main-foreground-opacity-30);
}
.history-item-progress-icon:after {
  top: 20px;
  margin-left: -11px;
  fill: var(--main-foreground-opacity-30);
  border-left: 2px solid var(--main-foreground-opacity-30);
}
.history-item-progress-icon-failure svg {
  fill: var(--danger);
}
.history-item-progress-icon-success svg {
  fill: var(--accent-color);
}
.history-item-progress-icon-success:after {
  border-color: var(--accent-color);
}

{# /* // History Canceled */ #}

.history-canceled {
  border-top-right-radius: var(--border-radius);
  border-top-left-radius: var(--border-radius);
}
.history-canceled-header {
  border-color: var(--border-color);
  border-top-left-radius: var(--border-radius);
  border-top-right-radius: var(--border-radius);
}
.history-canceled-icon svg {
  fill: var(--main-foreground-opacity-50);
}

{# /* // Offline Payment */ #}

.ticket-coupon {
  background: var(--main-foreground-opacity-05);
  border-color: var(--border-color);
}

{# /* // Buy fast */ #}
.panel-buy-fast {
  color: var(--main-foreground);
  fill: var(--main-foreground);
  background: var(--main-background);
  border: 1px solid var(--main-foreground-opacity-15);
  border-radius: var(--border-radius);
  box-shadow: none;
}

{# /* // Status, Destination & Sign Up */ #}

.success-order-id {
  padding-top: 52px;
  font-size: var(--font-small);
  text-transform: uppercase;
  .opacity-50 {
    opacity: 1 !important;
  }
}

.status,
.destination,
.signup {
  padding: 15px 0 !important;
  &-icon {
    width: 10px;
    margin: 0;
    svg {
      left: initial;
      width: 15px;
      fill: var(--main-foreground);
    }
  }
  &-content {
    width: calc(100% - 80px);
    margin: 4px 0 0 20px;
  }
}

.status,
.orderstatus {
  margin: 0;
  background: var(--main-background);
}

.destination {
  align-items: initial;
}

.destination-content .m-top-half {
  margin-top: 2px!important;
}

.orderstatus .destination {
    padding: 10px 0 0;
    border: 0;
}

.signup .icon-inside-input.align-right-password {
  right: 15px;
}

{# /* // Tracking */ #}

.history-item-progress {
  width: 70px;
  margin: -2px 0 0 0;
}

.history-item-content {
  width: calc(100% - 80px);
  max-width: 100%;
}

.history-item-message {
  max-width: 100%;
  font-size: var(--font-smallest);
}

.tracking-item-time {
  color: var(--main-foreground);
}

{# /* // WhatsApp Opt-in */ #}

.whatsapp-form input,
.whatsapp-form .input-group-addon {
  border-color: var(--accent-color);
}

{# /* // Helpers */ #}

.border-top {
  border-color: var(--border-color);
}

{# /* // Errors */ #}

.alert-danger-bagged {
  margin-top: 5px;
  border-radius: var(--border-radius);
  float: left;
  background: none;
  color: #cc4845;
}

.general-error {
  background: var(--danger);
  border-color: var(--danger);
}

{# /* // Badge */ #}

.badge {
  border: 0;
}

{# /* // Payment */ #}

.payment-category-label {
  font-size: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;

  &.text-semi-bold {
    font-weight: normal;
  }
}

.payment-item-discount {
  display: inline-block;
  float: left;
  clear: initial;
  margin: -1px 0 0 10px;
  padding: 4px 6px;
  color: var(--label-foreground);
  background: var(--label-background);
  border-radius: 6px;
  font-size: var(--font-smallest);
  text-transform: uppercase;
}

.payment-option {
  border-radius: 0;
  color: var(--main-foreground);
  background-color: var(--main-foreground-opacity-05);
  border: 0;
}

.radio-content.payment-option-content {
  background: var(--main-background);
  border: 1px solid var(--main-foreground-opacity-10);
  border-top: 0;
  border-radius: 0;
}


{# /* // Overlay */ #}

.overlay {
  background: var(--main-foreground-opacity-15);
}
.overlay-title {
  color: var(--main-foreground-opacity-60);
}

{# /* // List Picker */ #}

.list-picker .unchecked {
  fill: var(--main-foreground);
}
.list-picker li {
  border-color: var(--border-color);
  background: var(--main-background);

  &:hover {
    color: var(--accent-color);
  }

  &.active {
    background: var(--main-background);
    color: var(--accent-color);

    .checked {
      fill: var(--accent-color);
    }
  }
}

.list-picker-content {
  background: var(--main-background);
  border-color: var(--border-color);
}

{# /* // Loading */ #}

.loading {
  background: var(--main-background-opacity-50);
  color: var(--accent-color);
}
.loading-spinner {
  color: var(--accent-color);
}
.loading-skeleton-radio {
  margin: 0 0 10px 0;
  padding: 15px;
  border-color: var(--main-foreground-opacity-15);
  border-radius: 0;
}

{# /* // Spinner */ #}

.round-spinner {
  border-color: var(--accent-color);
  border-left-color: var(--accent-color-opacity-50);

  &:after {
    border-color: var(--accent-color);
    border-left-color: var(--accent-color-opacity-50);
  }
}

.spinner > .spinner-elem {
  width: 6px;
  height: 6px;
}

.spinner-inverted > .spinner-elem {
  background: var(--button-foreground);
}

{# /* // Modal */ #}

.modal-dialog,
.modal .modal-dialog {
  background: var(--main-background);
  fill: var(--main-foreground);
}

.modal .modal-header .modal-close {
  color: var(--main-foreground);
  text-shadow: none;
}

{# /* // List */ #}

.list-group-item {
  border-color: var(--main-foreground-opacity-15);
}

{# /* // Announcement */ #}

.announcement {
  color: var(--accent-color-opacity-80);

  &-bg {
    background: var(--accent-color);
    box-shadow: 0px 3px 5px -1px var(--accent-color-opacity-10);
    border-radius: var(--border-radius);
  }

  &-close {
    color: var(--accent-color);
  }
}

{# /* // Alert */ #}

.alert {
  border-radius: var(--border-radius);
  &-info {
    background-color: var(--accent-color-opacity-15);
    border-color: var(--accent-color-opacity-20);
    color: var(--accent-color);
    .alert-icon {
      fill: var(--accent-color);
    }
  }
}

{# /* // Chip */ #}

.chip {
  background-color: var(--accent-color-opacity-15);
  color: var(--accent-color);
  border-radius: 5px;
}

{# /* // Review Block Detailed  */ #}
.price--display__free {
  color: var(--accent-color);
}

.review-block-detailed {
  margin: 0 !important;
  background: var(--main-background);
  border: none;
  border-radius: var(--border-radius);
  &-item {
    width: 100%;
    background: transparent;
    border-radius: 0;
    &.review-block-dropdown {
        padding-top: 0;
    }
  }
}

.review-block-detailed-item .icon-area {
  flex-basis: 30px;
}

{# /* // Tooltip */ #}

.tooltip-icon {
  fill: var(--main-foreground);
}

{# /* // Tabs */ #}

.tabs-wrapper {
  border-top-right-radius: var(--border-radius);
  border-top-left-radius: var(--border-radius);
  background: var(--main-foreground-opacity-05);
  border-bottom-color: var(--main-foreground-opacity-10);
}

.tab-item.active {
  color: var(--accent-color);
  font-weight: bold;
}

.tab-indicator {
  background-color: var(--accent-color);
}

{#/*============================================================================
  #Media queries
==============================================================================*/ #}

{# /* // Max width 576px */ #}

@media (max-width: $sm) {

  .headbar .container .row .col {
    flex-basis: auto;
    &.text-left {
      flex: 0 0 100%;
      max-width: 100%;
      order: 2;
      margin: 0;
      padding: 10px 15px;
      {% if settings.logo_position_mobile == 'center' %}
        text-align: center !important;
      {% else %}
        text-align: left !important;
      {% endif %}
    }
    &.text-right {
      background: #aac67b;
      text-align: center !important;
    }
  }

  .headbar-logo-text {
    display: inline-block;
    margin: 8px 0;
  }

  .security-seal {
    color: #000000;

    .d-inline-block:first-child {
      position: absolute;
      top: 1px;
      left: 50%;
      margin-left: -13px;
    }
    p {
      display: inline-block;
      &.text-semi-bold {
        margin-right: 50px !important;
      }
    }
    &-badge {
      margin: 0;
    }
  }

  .box-discount-coupon-applied {
    border: 1px solid var(--main-foreground-opacity-20) !important;
  }
  .box-discount-coupon .form-control {
    border: 1px solid var(--main-foreground-opacity-20);
    border-radius: var(--border-radius);
  }
  .summary .panel {
    border: 0;
  }
  .summary-container .container {
    padding: 0;
  }
  .summary-coupon {
    padding-top: 65px;
  }

  .btn-primary {
    margin: 0 !important;
  }

  .panel.summary-details {
    border: 0;
  }

  .payment-list-item .accordion-section-header-label {
    flex-direction: column;
  }

  .accordion-section-header-label {
    align-items: start;
    align-content: start;
  }

  .payment-item-discount {
    margin: 8px 0 0;
  }

  .user-detail-icon {
    width: 20px;
    margin-right: 10px;
  }

  .user-detail-content {
    width: calc(100% - 80px);
  }

  .orderstatus-footer {
    background: var(--main-background);
  }

}

{# /* // Min width 768px */ #}

@media (min-width: $md) {

  .container {
    max-width: 1000px;
  }

  .headbar {
    padding: 8px 0;
  }

  .success-order-id {
    padding-top: 0;
  }

  .table.table-scrollable {
    padding: 0;
  }

}

{# /* // Max width 0px */ #}

@media (max-width: $xs) {

  .modal-xs {
    background: var(--main-background);
  }

}

{% endif %}
