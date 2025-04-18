Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do

      post '/login', to: 'sessions#login'
      post '/signup', to: 'sessions#signup'
      delete '/logout', to: 'sessions#logout'
      resources :expenses, only: [:index, :show, :create]
      resources :groups, only: [:index, :show, :create, :update, :destroy]
      get '/dashboard/friends', to: 'dashboard#friends'
      get '/dashboard/activities', to: 'dashboard#activities'
      post '/settlements', to: 'settlements#create'
  end
  devise_for :users, path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'signup',
    password: 'password',
    edit: 'profile'
  },controllers: {
    registrations: 'users', # Override default registrations controller
    sessions: 'sessions'
  }

  # Scope root under Devise
  devise_scope :user do
    root "devise/sessions#new"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard
  get "/dashboard", to: "dashboard#show", as: "dashboard"

  # Transactions
  get "/transactions", to: "transaction_histories#index", as: :transactions

  # Friend Requests
  resources :friend_requests, only: [:create] do
    collection do
      get 'accept'
    end
  end

  # Friendships
  resources :friendships, only: [:new, :create]

  # Groups
  resources :groups, only: [:create, :show, :destroy, :edit, :update] do
    member do
      get 'generate_invite_token'
      get 'invite', to: 'groups#invite', as: 'invite'
      post 'add_member'
      post 'add_member_email', to: 'groups#add_member_email', as: 'add_member_email'
    end
    get 'balances', to: 'balances#show', as: :balance
    resources :settlements, only: [:new, :create] do
      collection do
        get 'new/:payee_id', action: :new, as: :new_with_payee
      end
    end
    resources :expenses, only: [:new, :create, :edit, :update]
  end

  # Group Memberships
  resources :group_memberships, only: [:create, :destroy]

  # Group invite link
  get 'groups/invite/:token', to: 'groups#invite', as: 'group_invite'
end