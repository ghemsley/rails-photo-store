Rails.application.routes.draw do
  resources :categories do
    resources :products do
      resources :dimensions, only: %i[new create edit update destroy] do
        resources :price_modifiers, only: %i[edit update]
      end
    end
  end

  resources :users
  # resources :users do
  #   resources :carts
  #   resources :orders
  # end

  resources :admins

  resources :quantities, only: %i[index show create update destroy]

  get '/signin', to: 'sessions#new', as: :signin_form
  post '/signin', to: 'sessions#create', as: :signin
  get '/signout', to: 'sessions#destroy', as: :signout

  get '/admin_signin', to: 'sessions#admin_new', as: :admin_signin_form
  post '/admin_signin', to: 'sessions#admin_create', as: :admin_signin
  get '/admin_signout', to: 'sessions#admin_destroy', as: :admin_signout

  get '/search', to: 'searches#search', as: :search

  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
