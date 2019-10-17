Rails.application.routes.draw do
  # devise_for :operators
  root 'users/loc_districts#index'

  post 'search_product', to: 'application#search_product'

  devise_for :admin_users, path: :admin, controllers: {
      sessions: 'admin_users/sessions',
      registrations: 'admin_users/registrations',
      passwords: 'admin_users/passwords'
  }

  devise_scope :admin_user do
    get 'admin/passwords/edit_password', to: 'admin_users/registrations#edit_password'
    patch 'admin/passwords', to: 'admin_users/registrations#update_password'
  end

  devise_for :users, path: :user, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions',
      passwords: 'users/passwords',
  }

  devise_scope :user do
    get 'user/passwords/edit_password', to: 'users/registrations#edit_password'
    patch 'user/passwords', to: 'users/registrations#update_password'
  end

  devise_for :operators, path: :operator, controllers: {
      registrations: 'operators/registrations',
      sessions: 'operators/sessions',
      passwords: 'operators/passwords',
  }

  devise_scope :operator do
    get 'operator/passwords/edit_password', to: 'operators/registrations#edit_password'
    patch 'operator/passwords', to: 'operators/registrations#update_password'
  end


  namespace :admin_users, path: :admin do
    root 'users#index'
    resources :administrators, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :users, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
      member do
        get 'user_sign_in'
      end
    end

    match "*any", to: "base#routing_error", via: :all
  end

  namespace :users, path: :user do
    root "loc_districts#index"

    namespace :calc do
      get 'vrptw'
    end

    resources :locations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :loc_districts, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :loc_khoroos, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_categorys, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_suppliers, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :product_features, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_feature_options, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :products, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
      collection do
        patch 'get_product_category_children'
      end
    end
    resources :product_feature_rels, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_supply_orders, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_supply_order_items, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_locations, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_incomes, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_income_items, only: [:index, :create, :new, :edit, :update, :destroy] do
      collection do
        patch 'get_location_children'
        patch 'get_supply_order_info'
      end
    end
    resources :operators, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
      member do
        get 'operator_sign_in'
      end
    end

    match "*any", to: "base#routing_error", via: :all
  end

  namespace :operators, path: :operator do
    root 'product_sales#index'

    resources :product_sales, only: [:index, :create, :new, :show, :edit, :update] do
      collection do
        patch 'get_sub_status'
        patch 'get_product_features'
        post 'search_locations'
      end
    end

    match "*any", to: "base#routing_error", via: :all
  end

  match "*any", to: "application#routing_error", via: :all
end
