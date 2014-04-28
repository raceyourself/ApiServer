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
      # Native access token is already long-term
      server_token = provider_token[:access_token]
      raise 'No access token supplied for ' + provider_token[:provider] unless server_token

      auth = Authentication.where(provider: provider_token[:provider], uid: provider_token[:uid]).first
      unless auth
        auth = user.authentications.build.tap do |a|
          a.provider = provider_token[:provider]
          a.uid = provider_token[:uid]
        end 
      end
      raise 'Uid already in use by another user' unless auth.user_id == user.id
      auth.update_from_access_token(server_token)
      auth.save!

      # Update friends list
      case auth.provider
      when 'facebook'
        FacebookFriendsWorker.perform_async(user.id)
      when 'twitter'
        TwitterFriendsWorker.perform_async(user.id)
      when 'gplus'
        GplusFriendsWorker.perform_async(user.id)
      end

      show()
    end

  end
end
