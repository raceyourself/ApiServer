require 'gcm'

class PushNotificationWorker
  include Sidekiq::Worker
    
  def perform(user_id, data)
    reg_ids = Device.where(user_id: user_id).where(:push_id.exists => true).flat_map {|d| d.push_id}
    return if reg_ids.empty?
    options = {data: data}
    gcm = GCM.new(CONFIG[:google][:api_key])
    response = gcm.send_notification(reg_ids, options)
    logger.info response
  end
    
end
