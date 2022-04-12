# https://www.bigbinary.com/learn-rubyonrails-book/background-job-processing-using-sidekiq
# size: 4 -> WARN: ArgumentError: Your Redis connection pool is too small for Sidekiq to work. Your pool has 4 connections but must have at least 7
# https://stackoverflow.com/questions/38290868/configuring-puma-and-sidekiq 
# Remove the size: attribute in your configure_* blocks. Let Sidekiq manage the size for you.
# Extra bits for Web UI from https://www.youtube.com/watch?v=5wwhmgGZJbI and
# https://github.com/MikeRogers0-YouTube/DeployingToHeroku/blob/master/config/initializers/opinionated_defaults/sidekiq.rb
if defined?(Sidekiq) && ENV['REDIS_URL'].present?
  require 'sidekiq/web'
  require 'sidekiq/cron/web' if defined?(Sidekiq::Cron)
  Sidekiq.configure_client do |config|
    # config.redis = { url: ENV['REDIS_URL'], size: 4, network_timeout: 5 }
    config.redis = { url: ENV['REDIS_URL'], network_timeout: 5 }
  end

  Sidekiq.configure_server do |config|
    # config.redis = { url: ENV['REDIS_URL'], size: 4, network_timeout: 5 }
    config.redis = { url: ENV['REDIS_URL'], network_timeout: 5 }
  end
end