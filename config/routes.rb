GfAuthenticate::Application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations' }

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
      resource :credentials, only: [:show]
      resources :devices
      resources :transactions
      resources :tracks
      resources :friends
      resources :orientations
      resources :positions

      get 'data', to: 'data#index'
      post 'data', to: 'data#create'
      post 'delayed_data', to: 'data#delayed_create'
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

  root to: 'home#index'
end
