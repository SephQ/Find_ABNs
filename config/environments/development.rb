require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
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

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # SF 220408 - adding Email support
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { 
  # :host => '<your_url_here>', 
  :host => 'localhost:3000', 
  :protocol => 'http'
  }
  config.action_mailer.smtp_settings = {
  :address => 'smtp.gmail.com',
  # :port => 601,
  :port => 587,
  :domain => "gmail.com", # SF 220411 https://stackoverflow.com/questions/25872389/rails-4-how-to-correctly-configure-smtp-settings-gmail
  :user_name => ENV["GMAIL_USERNAME"], # "ses.abns@gmail.com"
  :password => ENV["GMAIL_PW"],
  # :authentication => 'plain',
  :authentication => 'login', # SF 220411 https://stackoverflow.com/questions/25872389/rails-4-how-to-correctly-configure-smtp-settings-gmail
  :enable_starttls_auto => true
  }
  # Allow less secure apps: ON
  # On May 30, 2022, this setting will no longer be available. - will need 2-step verification and an app password

  # https://guides.rubyonrails.org/action_mailer_basics.html
  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.default_url_options = { 
  # :host => 'localhost:3000', 
  # :protocol => 'http'
  # }
  # config.action_mailer.delivery_method = :sendmail
  # # Defaults to:
  # # config.action_mailer.sendmail_settings = {
  # #   location: '/usr/sbin/sendmail',
  # #   arguments: '-i'
  # # }
  config.action_mailer.perform_deliveries = true

  config.action_mailer.raise_delivery_errors = true # Temporary

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end
