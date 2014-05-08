module Api
  class CredentialsController < BaseController
    doorkeeper_for :all
    
    def show
      expose user, include: { authentications: { only: [ :provider, :uid, :permissions ] } }
    end

    def create
      path_params = request.path_parameters
      post_params = params.except(*path_params.keys)
      
      user_attributes = post_params.slice(:username, :name, :gender, :profile).permit!
      if user_attributes[:profile]
        # Merge profile (potential race condition)
        profile = user.profile || {}
        profile.merge!(user_attributes[:profile])
        profile.delete_if { |k,v| v.nil? }
        user_attributes[:profile] = profile
      end

      user.update_attributes!(user_attributes)

      # TODO: Move params to a more relevant json path: ie. authentications/{provider, uid, access_token}
      link_provider(post_params[:provider], post_params[:uid], post_params[:access_token]) if post_params[:access_token]

      show()
    end

    def link_provider(provider, uid, access_token)
      # server_token = Authentication.exchange_access_token(provider, access_token)
      # Native access token is already long-term

      auth = Authentication.where(provider: provider, uid: uid).first
      unless auth
        auth = user.authentications.build.tap do |a|
          a.provider = provider
          a.uid = uid
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

    end

  end
end
