Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :customers, controllers: {
    registrations: 'users/registrations'
  }

  ActiveAdmin.routes(self)
  root "home#home"

  resources :order_items
  resources :orders
  resources :events
  resources :customers
  resources :categories
  resources :products

  resource :cart, only: [:show] do
    post 'add_product/:product_id', to: 'carts#add_product', as: 'add_product'
    post 'remove_product/:product_id', to: 'carts#remove_product', as: 'remove_product'
    get 'checkout', to: 'carts#checkout', as: 'checkout'
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
