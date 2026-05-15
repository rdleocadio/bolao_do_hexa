# Puma can serve each request in a thread from an internal thread pool.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }

threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV") { "development" }

environment rails_env

if rails_env == "production"
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { 0 })

  if worker_count.positive?
    workers worker_count
    preload_app!
  end
end

# Allow puma to be restarted by `bin/rails restart`
plugin :tmp_restart

# Port configuration
port ENV.fetch("PORT") { 3000 }

# PID file
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Prevent worker timeout in development
worker_timeout 3600 if rails_env == "development"
