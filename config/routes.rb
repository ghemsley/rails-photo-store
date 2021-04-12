Rails.application.routes.draw do
  resources :categories do
    resources :products, only: %i[index new create] do
      resources :dimensions, only: %i[new create]
    end
  end

  get '/products/popular', to: 'products#popular', as: :popular_products
  resources :products, only: %i[show edit update destroy]
  resources :dimensions, only: %i[edit update destroy]
  resources :price_modifiers, only: %i[edit update]

  resources :users
  resources :admins

  get '/search', to: 'searches#search', as: :search

  get '/signin', to: 'sessions#new', as: :signin_form
  post '/signin', to: 'sessions#create', as: :signin
  get '/signout', to: 'sessions#destroy', as: :signout

  get '/admin_signin', to: 'sessions#admin_new', as: :admin_signin_form
  post '/admin_signin', to: 'sessions#admin_create', as: :admin_signin
  get '/admin_signout', to: 'sessions#admin_destroy', as: :admin_signout

  get '/sso_redirect', to: 'sessions#sso_redirect', as: :sso_redirect
  get '/reverse_sso_redirect', to: 'sessions#reverse_sso_redirect', as: :reverse_sso_redirect

  post '/foxycart_webhook', to: 'webhooks#foxycart_webhook', as: :foxycart_webhook

  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
