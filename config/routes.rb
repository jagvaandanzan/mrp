Rails.application.routes.draw do
  root 'users/loc_districts#index'

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

    resources :locations, only: [:index, :create, :new, :show, :edit, :update, :destroy]
    resources :loc_districts, only: [:index, :create, :new, :edit, :update, :destroy]
    resources :loc_khoroos, only: [:index, :create, :new, :edit, :update, :destroy]

    match "*any", to: "base#routing_error", via: :all
  end

  match "*any", to: "application#routing_error", via: :all
end
