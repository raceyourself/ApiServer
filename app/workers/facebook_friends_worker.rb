class FacebookFriendsWorker
  include Sidekiq::Worker

  @@FAIL_FAST = true

  def perform(user_id)
    user = User.where(id: user_id).first
    return if user.nil?
    auth = Authentication.where(provider: 'facebook', user_id: user.id).last
    graph = Koala::Facebook::API.new(auth.token)
    begin
      profile = graph.get_object("me")
    rescue => Koala::Facebook::AuthenticationError
      auth.destroy
      return
    end
    me = FacebookIdentity.new().update_from_facebook(profile)
    me.user_id = user.id
    me = me.merge
    return if me.refreshed_at > 5.minutes.ago
    ActiveRecord::Base.transaction do
      me.update!(:refreshed_at => Time.now)
      me.friendships.where(:friend_type => 'FacebookIdentity').destroy_all
      result = graph.get_connections("me", "friends", :fields=>"name,id,picture.width(256).height(256)") || []
      begin
        result.each do |friend|
          fid = FacebookIdentity.new().update_from_facebook(friend)
          fid = fid.merge
          fs = Friendship.new( identity: me, friend: fid )
          fs = fs.merge
        end
        result = result.next_page || []
      end while not result.empty?
    end
  end
end
