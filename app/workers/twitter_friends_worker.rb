class TwitterFriendsWorker
  include Sidekiq::Worker

  @@FAIL_FAST = true

  def perform(user_id)
    user = User.where(id: user_id).first
    auth = Authentication.where(provider: 'twitter', user_id: user.id).last
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
    me.user_id = user.id
    me = me.merge
    return if me.refreshed_at > 5.minutes.ago
    ActiveRecord::Base.transaction do
      me.update!(:refreshed_at => Time.now)
      me.friendships.where(:friend_type => 'TwitterIdentity').destroy_all
      get_twitter_friends(client).each do |friend|
        fid = TwitterIdentity.new().update_from_twitter(friend)
        fid = fid.merge
        fs = Friendship.new( identity: me, friend: fid )
        fs = fs.merge
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
end
