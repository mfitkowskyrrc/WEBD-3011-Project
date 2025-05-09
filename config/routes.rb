Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :customers, controllers: {
    registrations: "customers/registrations",
    sessions: "customers/sessions"
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
    post "add_product/:product_id", to: "carts#add_product", as: "add_product"
    post "remove_product/:product_id", to: "carts#remove_product", as: "remove_product"
    post "update_quantity/:cart_item_id", to: "carts#update_quantity", as: "update_quantity"
    get "checkout", to: "carts#checkout", as: "checkout"
    post "complete_purchase", to: "carts#complete_purchase", as: "complete_purchase"
    post "create_checkout_session", to: "carts#create_checkout_session", as: "create_checkout_session"

    get "checkout/success", to: "carts#checkout_success", as: "checkout_success"
    get "checkout/cancel", to: "carts#checkout_cancel", as: "checkout_cancel"
  end

  get "home", to: "home#home"
  get "home/edit/:section", to: "home#edit", as: "edit_content"
  patch "home/update", to: "home#update", as: "home_update"

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
