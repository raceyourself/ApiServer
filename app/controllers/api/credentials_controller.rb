module Api
  class CredentialsController < BaseController
    doorkeeper_for :all
    
    def show
      expose user, include: { authentications: { only: [ :provider, :uid, :permissions ] } }
    end

    def create
      path_params = request.path_parameters
      provider_token = params.except(*path_params.keys)
      # server_token = Authentication.exchange_access_token(provider_token[:provider], provider_token[:access_token])
      # raise 'Could not exchange access token with ' + provider_token[:provider] unless server_token
      # Native access token is already long-term
      server_token = provider_token[:access_token]
      auth = ::Authentications.where(provider: provider_token[:provider], uid: provider_token[:uid]).first
      unless auth
        auth = user.authentications.build.tap do |a|
          a.provider = provider_token[:provider]
          a.uid = provider_token[:uid]
        end 
        auth.update_from_access_token(server_token)
        auth.save!
      end
      show()
    end

  end
end
