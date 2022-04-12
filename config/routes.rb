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
end
