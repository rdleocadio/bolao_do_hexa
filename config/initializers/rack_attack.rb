class Rack::Attack
  # Limita requests por IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Limita tentativas de login
  throttle('logins/ip', limit: 10, period: 20.seconds) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Bloqueia scanners comuns
  blocklist('block suspicious paths') do |req|
    paths = [
      '/wp-admin',
      '/wp-login',
      '/xmlrpc.php',
      '/.git',
      '/phpmyadmin'
    ]

    paths.any? { |path| req.path.include?(path) }
  end
end

# Logging de bloqueios
ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
  req = payload[:request]

  Rails.logger.info "[Rack::Attack] Blocked IP #{req.ip} to #{req.path}"
end
