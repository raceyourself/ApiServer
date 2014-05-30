class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :device

  def merge
    self.save!
    self
  end

  def pretty_segmentation_characteristics
    d = {
      "Software version" => self.version,
      "username" => self.user.name
    }
  end

  after_commit :after_commit_callback, :on => [:create, :update]

  def after_commit_callback
    
    # send event analytics
    send_analytics
    
    # if the event has type "event", it might be a user milestone - save to user profile
    if (self.data["event_type"] == "event" && !self.data["event_name"].nil?)
      self.user.update_ux_milestones([self.data["event_name"]])  # update_ux_milestones expects an array of milestone names to be passed
    end
    
  end

  def send_analytics

    event = case self.data["event_type"]
      when "event" then "E: " + self.data["event_name"]
      when "screen" then "S: " + self.data["screen_name"]
      else "unknown"
    end
    
    properties = self.pretty_segmentation_characteristics
               .merge(self.device.pretty_segmentation_characteristics)
               .merge(self.user.pretty_segmentation_characteristics)

    logger.info("Sending event to segment.io: " + event + " " + properties.inspect)

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
