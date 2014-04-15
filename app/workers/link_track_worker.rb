class LinkTrackWorker
  include Sidekiq::Worker
    
  def perform(user_id, friend_id, track_cid, message)
    user = User.where(id: user_id).first
    friend = Identity.where(id: friend_id).first
    track = Track.where(device_id: track_cid[0], track_id: track_cid[1])
    link(user, friend, track, message)
  end
   
  def link(user, friend, track, message)
    auth = Authentication.where(provider: 'facebook', user_id: user.id).first
    raise "User has not authenticated with facebook" if auth.nil?
    raise "User has not authorized share permissions for facebook" if auth.permissions !~ /share/
    url = 'http://lotophage.com/alt_/glass_course.html'
    graph = Koala::Facebook::API.new(auth.token)
    graph.put_connections(friend.uid, "links", { :link => url, 
                                               :message => message,
                                               :name => "What name?",
                                               :caption => "Captain!",
                                               :description => "Describe it!",
                                               :picture => "http://lotophage.com/alt_/thing.png" })
  end
    
end
