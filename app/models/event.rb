class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
    self
  end

  after_commit :send_analytics, :on => :create

  def send_analytics
    logger.info("Event.send_analytics called")

    Analytics.identify(
      user_id: self.user_id,
      traits: {
        version: self.version,
        device_id: self.device_id,
        session_id: self.session_id,
        data: data
      },
      timestamp: self.ts
    )

  end

end
