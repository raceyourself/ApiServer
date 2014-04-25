require 'google/api_client'
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  @@FAIL_FAST = true

    def facebook
      standard_provider
      if @user.persisted?
        auth = Authentication.where(provider: 'facebook', user_id: @user.id).first
        graph = Koala::Facebook::API.new(auth.token)
        profile = graph.get_object("me")
        me = FacebookIdentity.new().update_from_facebook(profile)
        me.user_id = @user.id
        me.upsert if me.valid?
        # Race condition
        me.friendships.destroy_all(friend_type: 'FacebookIdentity')
        result = graph.get_connections("me", "friends", :fields=>"name,id,picture") || []
        begin
          result.each do |friend|
            fid = FacebookIdentity.new().update_from_facebook(friend)
            fid.merge
            fs = Friendship.new( identity: me, friend: fid )
            fs.merge
          end
          result = result.next_page || []
        end while not result.empty?
      end
    end

    def twitter
      standard_provider
      if @user.persisted?
        auth = Authentication.where(provider: 'twitter', user_id: @user.id).first
        client = Twitter::REST::Client.new do |config| 
          config.consumer_key = CONFIG[:twitter][:client_id]
          config.consumer_secret = CONFIG[:twitter][:client_secret]
          config.oauth_token = auth.token
          config.oauth_token_secret = auth.token_secret
        end
        begin
          credentials = client.verify_credentials
        rescue Twitter::Error::TooManyRequests => error
          logger.warn "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds..."
          sleep error.rate_limit.reset_in
          retry
        end
        me = TwitterIdentity.new().update_from_twitter(credentials)
        me.user_id = @user.id
        me.upsert if me.valid?
        # Race condition
        me.friendships.destroy_all(friend_type: 'TwitterIdentity')
        get_twitter_friends(client).each do |friend|
          fid = TwitterIdentity.new().update_from_twitter(friend)
          fid.merge
          fs = Friendship.new( identity: me, friend: fid )
          fs.merge
        end
      end
    end

    def get_twitter_friends(client)
      begin
        client.friends.to_a
      rescue Twitter::Error::TooManyRequests => error
        logger.warn "Twitter rate limited and fail-fast enabled, aborting!" if @@FAIL_FAST
        return []
        logger.warn "Rate limit error, sleeping for #{error.rate_limit.reset_in} seconds..."
        sleep error.rate_limit.reset_in
        retry
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
        # Race condition
        me.friendships.destroy_all(friend_type: 'GplusIdentity')
        req = {
            :api_method => plus.people.list, 
            :parameters => {'collection' => 'visible', 'userId' => 'me'}
        }
        begin
          result = client.execute(req)
          result.data.items.each do |person|
            fid = GplusIdentity.new().update_from_gplus(person)
            fid.merge
            fs = Friendship.new( identity: me, friend: fid )
            fs.merge
          end
          if result.next_page_token
            req = result.next_page
          else
            req = nil
          end
        end while not req.nil?
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
          data = request.env["omniauth.auth"].except("extra")
          data["x-access-level"] = request.env["omniauth.auth"].extra.access_token.response.header["x-access-level"] if request.env["omniauth.auth"].extra
          session["devise.provider_data"] = data
          redirect_to new_user_registration_url
        end
      end #standard_provider

  end #OmniauthCallbacksController
end #Users 
