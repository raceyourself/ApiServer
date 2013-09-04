GfAuthenticate::Application.routes.draw do
  use_doorkeeper
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :api do
    api version: 1 do
      resource :credentials, only: [:show]
    end
  end

  namespace 'oauth' do
    
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
