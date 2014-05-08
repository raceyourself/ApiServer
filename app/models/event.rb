class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
    self
  end

  after_commit :send_analytics, :on => :create

  def send_analytics
    logger.info("Event.send_analytics called")
    details = self.data
    
    event = "unknown event"
    case details["event_type"]
    when "Flow state changed"
      event = "Flow state: " + details["flow_state"]
    else
      event = details["event_type"]
    end

    logger.info("Details is " + details.to_s)

    Analytics.track(
      user_id: self.user_id,
      event: event,
      properties: {
        version: self.version,
        device_id: self.device_id,
        session_id: self.session_id
      }.merge(details),
      timestamp: self.created_at
    )

  end

end
