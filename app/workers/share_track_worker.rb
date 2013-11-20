class ShareTrackWorker
  include Sidekiq::Worker
  @@external_web_url = 'http://race.lotophage.com/'
    
  def perform(user_id, track_cid, message)
    user = User.where(id: user_id).first
    track = Track.where(device_id: track_cid[0], track_id: track_cid[1]).first
    share(user, track, message)
  end
    
end
