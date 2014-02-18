require 'gcm'
require 'apns'

class PushNotificationWorker
  include Sidekiq::Worker
    
  def perform(user_id, data)
    # Android devices
    reg_ids = Device.where(user_id: user_id).where(:push_id.exists => true).where(:manufacturer.ne => 'Apple').flat_map {|d| d.push_id}
    unless reg_ids.empty?
      options = {data: data}
      gcm = GCM.new(CONFIG[:google][:api_key])
      response = gcm.send_notification(reg_ids.uniq, options)
      logger.info response
    end
    # iOS devices
    reg_ids = Device.where(user_id: user_id).where(:push_id.exists => true).where(:manufacturer => 'Apple').flat_map {|d| d.push_id}
    unless reg_ids.empty?
      APNS.host = CONFIG[:apple][:apns_host]
      APNS.pem = CONFIG[:apple][:apns_pem]
      notifications = []
      reg_ids.each do |device_token| 
        notifications << APNS::Notification.new(device_token, :alert => data[:title], :badge => 1, :sound => 'default', :content_available: 1)
      end
      APNS.send_notifications(notifications)
      logger.info notifications.length.to_s + " Apple push notifications sent"
      logger.info APNS.feedback
    end
  end
    
end
