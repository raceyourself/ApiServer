GfAuthenticate::Application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations', confirmations: 'confirmations' }
  devise_scope :user do
    patch "/confirm" => "confirmations#confirm"
  end

  #TODO: should use authenticate blocks

  mount RailsAdmin::Engine => 'admin', as: 'rails_admin', constraints: lambda { |request|
    request.env['warden'].authenticated? # are we authenticated?
    request.env['warden'].authenticate! # authenticate if not already
    request.env['warden'].user.admin?
  }

  require 'sidekiq/web'
  mount Sidekiq::Web => 'sidekiq', constraints: lambda { |request|
    request.env['warden'].authenticated? # are we authenticated?
    request.env['warden'].authenticate! # authenticate if not already
    request.env['warden'].user.admin?
  }

  namespace :api do
    api version: 1 do
      match 'me', to: 'credentials#show', via: 'get'
      resource :credentials
      resource :sign_up
      resources :providers
      resources :devices
      resources :transactions
      resources :tracks
      resources :friends
      resources :positions
      resources :challenges
      resources :configurations
      resources :games
      resources :invites

      get 'data', to: 'data#index'
      post 'data', to: 'data#create'
      post 'delayed_data', to: 'data#delayed_create'

      post 'sync/:ts', to: 'data#sync'
      get 'sync/:ts', to: 'data#sync'
      
      resources :users do
        resource :credentials, only: [:show]
        resources :devices
        resources :transactions
        resources :tracks
        resources :friends
        resources :positions
        resources :challenges
        resources :configurations
        resources :games
      end

    end
  end

  namespace :oauth do
    resources :applications do
      resources :access_tokens, only: [:create, :destroy]
    end
  end

  get '/api_docs/:version/:action.json', controller: 'api_docs'
  # FIXME: Any better way to redirect local calls (/api_dos/images/throbber.gif)
  get '/api_docs/:any/:resource.:ext', to: redirect('/api/%{any}/%{resource}.%{ext}')
  get '/api_docs', to: 'api_docs#index'

  get '/analytics', to: 'analytics#index'
  namespace :analytics do
    resources :events
    resources :queries
    resources :views
  end

  root to: 'home#index'
end
