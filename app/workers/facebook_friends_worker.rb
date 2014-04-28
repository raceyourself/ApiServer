class FacebookFriendsWorker
  include Sidekiq::Worker

  @@FAIL_FAST = true

  def perform(user_id)
    user = User.where(id: user_id).first
    auth = Authentication.where(provider: 'facebook', user_id: user.id).last
    graph = Koala::Facebook::API.new(auth.token)
    profile = graph.get_object("me")
    me = FacebookIdentity.new().update_from_facebook(profile)
    me.user_id = user.id
    me.merge
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
