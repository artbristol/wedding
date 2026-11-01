# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = {
    'cache-control' => "public, max-age=#{1.year.to_i}"
  }

  # Compress JavaScripts; do not fall back to compiling assets at runtime.
  config.assets.js_compressor = :terser
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = '/up'

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = {
    host: ENV.fetch('CANONICAL_HOST', nil),
    protocol: ENV['CANONICAL_HOST_PROTOCOL'] || 'https'
  }

  # SMTP settings are provided via environment variables. When SMTP_ADDRESS is
  # unset, fall back to the :test delivery method so RSVP submission still works
  # (emails are logged and discarded instead of being sent).
  if ENV['SMTP_ADDRESS']
    smtp = {
      address: ENV.fetch('SMTP_ADDRESS', nil),
      port: (ENV['SMTP_PORT'] || 587).to_i,
      domain: ENV.fetch('SMTP_DOMAIN', nil),
      user_name: ENV.fetch('SMTP_USER_NAME', nil),
      password: ENV.fetch('SMTP_PASSWORD', nil),
      authentication: ENV['SMTP_AUTHENTICATION'] || 'plain',
      enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false',
      imap_host: ENV.fetch('IMAP_HOST', nil),
      sent_folder: ENV['IMAP_SENT_FOLDER'] || 'Sent'
    }
    # NB: config.action_mailer is a plain OrderedOptions in Rails 8, so the
    # registration must go through ActionMailer::Base directly.
    ActionMailer::Base.add_delivery_method \
      :smtp_with_sent_copy, DeliveryMethods::SmtpWithSentCopy, **smtp
    config.action_mailer.delivery_method = :smtp_with_sent_copy
  else
    config.action_mailer.delivery_method = :test
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
