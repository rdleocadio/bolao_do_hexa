require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # config.require_master_key = true

  config.assets.compile = false

  config.active_storage.service = :local

  config.force_ssl = true

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # ===== MAILER / DEVISE =====

  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "seudominio.com"),
    protocol: "https"
  }

  Rails.application.routes.default_url_options[:host] = ENV.fetch("APP_HOST", "seudominio.com")
  Rails.application.routes.default_url_options[:protocol] = "https"

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    domain: ENV.fetch("SMTP_DOMAIN", "seudominio.com"),
    user_name: ENV.fetch("SMTP_USERNAME"),
    password: ENV.fetch("SMTP_PASSWORD"),
    authentication: "plain",
    enable_starttls_auto: true
  }

  # ===== I18N =====

  config.i18n.fallbacks = true

  # ===== DEPRECATIONS =====

  config.active_support.report_deprecations = false

  # ===== DATABASE =====

  config.active_record.dump_schema_after_migration = false

  # ===== HOSTS =====
  # Descomente e ajuste quando tiver domínio definido:
  #
  # config.hosts = [
  #   ENV.fetch("APP_HOST", "seudominio.com")
  # ]
  #
  # config.host_authorization = {
  #   exclude: ->(request) { request.path == "/up" }
  # }
end
