Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'SysUser', at: '/auth'
    end
    namespace :salesman do
      mount_devise_token_auth_for 'Salesman', at: '/auth'
    end
    namespace :user do
      mount_devise_token_auth_for 'User', at: '/auth'
    end
  end
  mount ActionCable.server, at: '/cable'
  mount API::Base => '/api'

  get 'fb_comment_path', to: 'application#fb_comment_path'
  root 'users/base#root'

  post 'search_product', to: 'application#search_product'
  post 'search_fb_answer', to: 'application#search_fb_answer'

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

  devise_for :logistics, path: :logistic, controllers: {
      registrations: 'logistics/registrations',
      sessions: 'logistics/sessions',
      passwords: 'logistics/passwords',
  }

  devise_scope :logistic do
    get 'logistic/passwords/edit_password', to: 'logistics/registrations#edit_password'
    patch 'logistic/passwords', to: 'logistics/registrations#update_password'
  end


  namespace :admin_users, path: :admin do
    root 'users#index'
    resources :administrators, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :users, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :logistics, only: [:index, :create, :new, :show, :edit, :update, :destroy]

    namespace :bank_logins do
      get 'login'
    end

    namespace :facebooks do
      get 'posts'
      get 'attachments'
      get 'to_archives'
    end

    match "*any", to: "base#routing_error", via: :all
  end

  namespace :users, path: :user do
    root "base#root"
    get "panel", to: 'pages#panel'
    post 'uploads' => 'uploads#create'

    namespace :calc do
      get 'vrptw'
    end

    resources :product_categories, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :customers, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :product_feature_groups, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_features, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :product_feature_options, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :category_filter_groups, only: [:index, :create, :new, :show, :edit, :update, :destroy], path: "category/filters"
    resources :product_discounts, only: [:create, :new, :edit, :update, :destroy]
    resources :product_feature_items, only: [:create, :new, :destroy] do
      collection do
        get 'balance'
        post 'get_feature_items'
        get 'set_balance'
        post 'load_features'
        post 'itoms'
        patch 'update_feature'
      end
    end
    resources :products, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
      collection do
        patch 'get_product_category_children'
        patch 'form_price'
        patch 'form_information'
        patch 'form_image_video'
        patch 'form_package'
        post 'technical_spec_items'
      end
    end
    resources :product_supply_orders, only: [:index, :create, :new, :edit, :show, :update, :destroy] do
      collection do
        patch 'form_feature'
        post 'last_product_price'
        get 'to_product'
      end
    end
    resources :product_locations, only: [:index, :create, :new, :edit, :update, :destroy]

    get 'product_incomes/shipping_show/:id', to: 'product_incomes#shipping_show'
    resources :product_incomes do
      collection do
        patch 'get_location_children'
        patch 'get_supply_order_info'
        patch 'insert_shipping_ub'
        get 'locations'
        patch 'set_location'
        post 'search_products'
        post 'search_supply_feature'
        post 'insert_sample_product'
        post 'income_logs'
        patch 'update_income_log'
      end
    end
    resources :operators, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :salesmen, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :ali_categories, only: [:index, :create, :show, :edit, :update, :destroy] do
      collection do
        patch 'set_prod'
        patch 'set_name_as_filter'
        get 'form_filter'
        patch 'update_filter'
      end
    end

    resources :bank_accounts, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :bank_dealing_accounts, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :brands, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :manufacturers, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :technical_specifications, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :size_instructions, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :fb_posts do
      collection do
        post 'download'
      end
    end
    resources :fb_comments, only: [:index, :show, :edit, :update, :destroy] do
      collection do
        patch 'hide'
      end
    end
    resources :fb_comment_archives, only: [:index, :show] do
      collection do
        get 'report'
        post 'get_message_url'
      end
    end
    resources :bank_transactions
    resources :sms_messages, only: [:index, :create, :new]
    namespace :delivery_reports do
      get 'index'
      get 'salary'
    end
    resources :sale_taxes, only: [:index, :create, :new, :edit, :update]
    resources :product_sales, only: [:index] do
      collection do
        post 'check_register'
        post 'tax'
      end
    end

    namespace :product_reports do
      get 'track'
      get 'track_logs'
      post 'track_log'
    end

    namespace :supply_calculations do
      get 'supply_orders'
      get 'income_products'
      patch 'set_calculated'
      get 'for_invoice'
      get 'purchased_er'
      get 'received_er'
    end

    match "*any", to: "base#routing_error", via: :all
  end

  namespace :operators, path: :operator do
    root "base#root"

    resources :product_sales, only: [:index, :create, :new, :show, :edit, :update, :destroy] do
      collection do
        patch 'get_product_features'
        post 'search_locations'
        post 'add_location'
        post 'search_khoroos'
        post 'get_last_location'
        post 'get_location'
        post 'get_product_balance'
        patch 'update_status'
        post 'get_bonus'
        post 'next_status'
      end
    end

    resources :fb_comments, only: [:index, :show, :edit, :update, :destroy] do
      collection do
        patch 'like'
        patch 'hide'
      end
    end
    resources :fb_comment_actions
    resources :fb_comment_archives, only: [:index, :show] do
      collection do
        get 'report'
        post 'get_message_url'
      end
    end

    resources :product_sale_calls, only: [:index, :new, :edit, :update, :show] do
      collection do
        post 'auto_save'
        post 'get_prev_sales'
        post 'check_sale_order'
      end
    end

    resources :bank_transactions, only: [:index]
    resources :sms_messages, only: [:index, :create, :new]
    resources :loc_districts, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :bonus, only: [:index, :edit, :update, :destroy]
    resources :loc_khoroos, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :locations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    namespace :distributing do
      get 'index'
      post 'set_travel'
      post 'travel_routes'
      post 'product_sales'
      post 'add_product_sale'
      post 'change_route_queue'
      patch 'remove_route'
      post 'distributing'
      post 'salesman_track'
    end
    match "*any", to: "base#routing_error", via: :all
  end

  namespace :logistics, path: :logistic do
    root "base#root"

    resources :supply_orders, only: [:index, :show, :edit, :update] do
      collection do
        post 'create_temp'
      end
    end
    resources :shipping_ers do
      collection do
        post 'search_supply_feature'
        post 'add_product'
      end
    end
    resources :shipping_ubs do
      collection do
        post 'add_product'
        post 'search_er_products'
      end
    end

    match "*any", to: "base#routing_error", via: :all
  end

  match "*any", to: "application#routing_error", via: :all
end
