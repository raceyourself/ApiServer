class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
    self
  end

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    logger.info("Event.send_analytics called")

    event = case self.data["event_type"]
      when "event" then "E: " + self.data["event_name"]
      when "screen" then "S: " + self.data["screen_name"]
      else "unknown"
    end
    
    properties = {
      version: self.version,
      user_id: self.user_id,
      device_id: self.device_id,
      session_id: self.session_id
    }.merge(self.data)

    logger.info("Event type " + event + " with properties: " + self.data.inspect)

    case self.data["event_type"]
      when "screen" then AnalyticsRuby.screen(
	user_id: self.user_id,
	name: event,
	properties: properties,
	timestamp: self.created_at,
	integrations: { "mixpanel" => false }
      )
      when "event" then AnalyticsRuby.track(
	user_id: self.user_id,
	event: event,
	properties: properties,
	timestamp: self.created_at
      )
      else logger.error("Unknown analytic event_type")
    end
  end

  logger.info("Event.send_analytics completed")

end
