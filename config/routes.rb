Rails.application.routes.draw do
  # Devise routes with custom OmniAuth callbacks
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # Marketing pages
  root "home#index"
  get "pricing", to: "home#pricing"
  get "terms", to: "home#terms"
  get "privacy", to: "home#privacy"

  # Member dashboard
  resource :dashboard, only: [:show], controller: "dashboard"
  resource :settings, only: [:show], controller: "settings"

  # Subscriptions
  resources :subscriptions, only: [:create] do
    collection do
      get :success
      get :cancel
      post :portal
    end
  end

  # Stripe webhooks
  namespace :webhooks do
    resources :stripe, only: [:create]
  end

  # Admin namespace
  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :show, :edit, :update] do
      member do
        post :impersonate
        post :comp_subscription
      end
    end
  end

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check
end
