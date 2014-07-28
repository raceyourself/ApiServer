class FacebookFriendsWorker
  include Sidekiq::Worker

  @@FAIL_FAST = true

  def perform(user_id)
    user = User.where(id: user_id).first
    return if user.nil?
    auth = Authentication.where(provider: 'facebook', user_id: user.id).last
    return if auth.nil?
    graph = Koala::Facebook::API.new(auth.token)
    begin
      profile = graph.get_object('me?fields=id,name,email,picture.width(256).height(256),gender,timezone')
    rescue Koala::Facebook::AuthenticationError => e
      auth.destroy
      return
    end
    me = FacebookIdentity.new().update_from_facebook(profile)
    me.user_id = user.id
    me = me.merge
    return if me.refreshed_at > 5.minutes.ago
    me.update!(:refreshed_at => Time.now)
    ActiveRecord::Base.transaction do
      count = 0
      friendship_ids = me.friendships.where(:friend_type => 'FacebookIdentity').map {|fs| fs.id}
      result = graph.get_connections("me", "friends", :fields=>"name,id,picture.width(256).height(256)") || []
      begin
        result.each do |friend|
          fid = FacebookIdentity.new().update_from_facebook(friend)
          fid = fid.merge
          fs = Friendship.new( identity: me, friend: fid )
          fs = fs.merge
          friendship_ids.delete(fs.id)
          count = count + 1
        end
        result = result.next_page || []
      end while not result.empty?
      friendship_ids.each do |id|
        Friendship.find(id).destroy
      end
      logger.info "Refreshed user #{user_id}'s #{count} facebook friends, #{friendship_ids.length} removed"
    end
    # Touch all changed friendships outside of transaction in case a sync happened while isolated
    me.friendships.where(:friend_type => 'FacebookIdentity')
                  .where('updated_at >= ?', me.refreshed_at).update_all(updated_at: Time.now)
  end
end
