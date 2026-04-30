require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Recarrega código automaticamente
  config.enable_reloading = true

  # Não faz eager load em dev
  config.eager_load = false

  # Mostra erros completos
  config.consider_all_requests_local = true

  # Server timing
  config.server_timing = true

  # Caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage
  config.active_storage.service = :local

  # Mailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_caching = false

  # Devise / URLs dos emails
  config.action_mailer.default_url_options = {
    host: "localhost",
    port: 3000
  }

  Rails.application.routes.default_url_options[:host] = "localhost"
  Rails.application.routes.default_url_options[:port] = 3000

  # Visualizar emails no navegador em desenvolvimento
  config.action_mailer.delivery_method = :letter_opener_web

  # Logs de depreciação
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Migrations pendentes
  config.active_record.migration_error = :page_load

  # Logs de queries
  config.active_record.verbose_query_logs = true

  # Logs de jobs
  config.active_job.verbose_enqueue_logs = true

  # Silencia logs de assets
  config.assets.quiet = true

  # Raise error quando callbacks inválidos
  config.action_controller.raise_on_missing_callback_actions = true
end
