module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook
      standard_provider
      if @user.persisted?
        auth = Authentication.where(provider: 'facebook', user_id: @user.id).first
        graph = Koala::Facebook::API.new(auth.token)
        profile = graph.get_object("me")
        me = FacebookIdentity.new().update_from_facebook(profile)
        me.user_id = @user.id
        me.upsert if me.valid?
        graph.get_connections("me", "friends").each do |friend|
          fid = FacebookIdentity.new().update_from_facebook(friend)
          fid.save!
          me.friendships << Friendship.new( friend: fid )
        end
      end
    end

    def twitter
      standard_provider
      if @user.persisted?
        auth = Authentication.where(provider: 'twitter', user_id: @user.id).first
        client = Twitter::Client.new(:consumer_key => CONFIG[:twitter][:client_id],
                                     :consumer_secret => CONFIG[:twitter][:client_secret],
                                     :oauth_token => auth.token,
                                     :oauth_token_secret => auth.token_secret)
        me = TwitterIdentity.new().update_from_twitter(client.verify_credentials)
        me.user_id = @user.id
        me.upsert if me.valid?
        client.friends.all.each do |friend|
          fid = TwitterIdentity.new().update_from_twitter(friend)
          fid.save!
          me.friendships << Friendship.new( friend: fid )
        end
      end
    end

    def gplus
      standard_provider
      if @user.persisted?
        auth = Authentication.where(provider: 'gplus', user_id: @user.id).first
        client = Google::APIClient.new()
        plus = client.discovered_api('plus')
        client.authorization.client_id = CONFIG[:gplus][:client_id]
        client.authorization.client_secret = CONFIG[:gplus][:client_secret]
        client.authorization.access_token = auth.token
        client.authorization.refresh_token = auth.refresh_token
        result = client.execute(
          :api_method => plus.people.get, 
          :parameters => {'userId' => 'me'}
        )
        me = GplusIdentity.new().update_from_gplus(result.data)
        me.user_id = @user.id
        me.upsert if me.valid?
        result = client.execute(
          :api_method => plus.people.list, 
          :parameters => {'collection' => 'visible', 'userId' => 'me'}
        )
        result.data.items.each do |person|
          fid = GplusIdentity.new().update_from_gplus(person)
          fid.save!
          me.friendships << Friendship.new( friend: fid )
        end
      end
    end


    protected

      def standard_provider
        @user = User.find_for_provider_oauth(request.env["omniauth.auth"], current_user)

        if @user.persisted?
          if current_user
            redirect_to root_url
          else
            sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            set_flash_message(:notice, :success, :kind => request.env["omniauth.auth"]["provider"].humanize) if is_navigational_format?
          end
        else
          session["devise.provider_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url
        end
      end #standard_provider

  end #OmniauthCallbacksController
end #Users 
