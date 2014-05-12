Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/1', namespace: 'glassfit' }
  config.error_handlers << Proc.new do |ex, ctx_hash|
    ErrorMailer.sidekiq_error(ex, ctx_hash)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/1', namespace: 'glassfit' }
end
