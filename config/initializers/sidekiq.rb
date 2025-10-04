# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  begin
    config.redis = { url: ENV.fetch("REDIS_URL") { "redis://redis:6379/0" } }
    Sidekiq.redis(&:ping)
  rescue Redis::CannotConnectError => e
    Rails.logger.warn "Redis não disponível ainda: #{e.message}"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") { "redis://redis:6379/0" } }
end
