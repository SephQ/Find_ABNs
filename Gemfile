source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.2", ">= 7.0.2.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:x64_mingw, :mingw, :mswin]
# Udemy Q&A Bogdan answer
gem 'tzinfo-data', '~> 1.2021', '>= 1.2021.5'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# SF gems added 220405 https://replit.com/@SephQuarius/ABN-Check?v=1#Gemfile
gem 'nokogiri'
gem 'open-uri'
# gem 'httparty'
gem 'open_uri_redirections'
# https://medium.com/@igor_marques/exporting-data-to-a-xlsx-spreadsheet-on-rails-7322d1c2c0e7
# gem 'rubyzip', '= 1.0.0'
# gem 'axlsx', '= 2.0.1'
# gem 'axlsx_rails'
# https://github.com/caxlsx/caxlsx_rails/issues/21 In your gemfile require axlsx 2.0.1 before axlsx_rails:
# gem 'axlsx', '~> 2.0.1'
# gem 'axlsx_rails'
# https://github.com/caxlsx/caxlsx_rails
gem 'caxlsx'
gem 'caxlsx_rails'
# https://github.com/collectiveidea/delayed_job (To avoid Heroku timeouts, not using Sidekiq because Windows-incompatible)
# gem 'delayed_job_active_record'
# gem 'daemons'

# Linux development 220410: Adding background jobs/sidekiq
# https://www.bigbinary.com/learn-rubyonrails-book/background-job-processing-using-sidekiq
gem 'sidekiq'

# https://serveanswer.com/questions/heroku-router-at-error-code-h10-desc-app-crashed-method
# Fixing Heroku app crashed error with bootsnap
# gem 'net-smtp', require: false
# gem 'net-pop', require: false
# gem 'net-imap', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # Use sqlite3 as the database for Active Record
  gem "sqlite3", "~> 1.4"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
  gem "pg"
end