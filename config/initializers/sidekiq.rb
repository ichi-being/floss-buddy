# SidekiqのRedis接続設定
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  Sidekiq::BasicFetch::TIMEOUT = 60
  Sidekiq::Launcher.send(:remove_const, 'BEAT_PAUSE')
  Sidekiq::Launcher.const_set('BEAT_PAUSE', 55)
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
