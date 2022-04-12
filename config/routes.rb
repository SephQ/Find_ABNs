Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "pages#home"
  get "ABN_export", to: "pages#ABN_export"
  get "ABN_email", to: "pages#ABN_email"
  get "dummyemail", to: "pages#dummyemail"
  # resources :pages do
  #   post :export, on: :collection, as: :export
  # end
  # https://medium.com/@galejscott/lead-me-up-the-rails-path-2d0b924e485
  resources :pages, only: [:index, :export, :dummyemail]
  if defined?(Sidekiq) && defined?(Sidekiq::Web)
    # From https://www.youtube.com/watch?v=5wwhmgGZJbI - Sidekiq Web UI
    # mount Sidekiq::Web => "/sidekiq"

    # https://www.aloucaslabs.com/miniposts/how-to-add-basic-http-authentication-to-sidekiq-ui-mounted-on-a-rails-application
    # Monitoring
    scope :monitoring do
      # Sidekiq Basic Auth from routes on production environment
      Sidekiq::Web.use Rack::Auth::Basic do |username, password|
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
          ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PW"]))
      end if Rails.env.production?

      mount Sidekiq::Web, at: '/sidekiq'
    end
  end
end
