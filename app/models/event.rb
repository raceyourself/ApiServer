class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
    self
  end

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    logger.info("Event.send_analytics called")
    details = self.data
    
    case details["event_type"]
    when "screen"  # unity screen transition
      AnalyticsRuby.screen(
        user_id: self.user_id,
        name: details["flow_state"],
        category: "unity",
        event: "S: " + details["screen_name"],
        properties: {
          version: self.version,
          device_id: self.device_id,
          session_id: self.session_id
        }.merge(details),
        timestamp: self.created_at
      )
    else  # other event
      AnalyticsRuby.track(
        user_id: self.user_id,
        event: "E: " + details["event_name"],
        name: "Name", 
        properties: {
          version: self.version,
          device_id: self.device_id,
          session_id: self.session_id
        }.merge(details),
        timestamp: self.created_at
      )
    end
  end

  logger.info("Event.send_analytics completed")

end
