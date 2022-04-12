# https://sentry.io/organizations/findabns/projects/findabns/getting-started/ruby-rails/
Sentry.init do |config|
  config.dsn = 'https://23207c3d9d664a378f643b6c41a5e24f@o1200620.ingest.sentry.io/6324700'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end if defined?(Sentry)