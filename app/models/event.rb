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

  # add device/user/challenge characteristics too
  def pretty_segmentation_characteristics2
    properties = self.pretty_segmentation_characteristics
                 .merge(self.device.pretty_segmentation_characteristics)
                 .merge(self.user.pretty_segmentation_characteristics)
    properties.merge!(Challenge.find(self.data["challenge_id"]).pretty_segmentation_characteristics) if self.data.keys.include?("challenge_id")
  end

  after_commit :after_commit_callback, :on => [:create, :update]

  def after_commit_callback
    
    # send event analytics
    send_analytics
    
    # if the event has type "event", it might be a user milestone - save to user profile
    if (self.data["event_type"] == "event" && !self.user.ux_milestones.include?(self.data["event_name"]))
      self.user.update_ux_milestones([self.data["event_name"]])  # update_ux_milestones expects an array of milestone names to be passed
    end

    # Trigger hello worker from UX milestone: 'first_tutorial'
    # TODO: Add !ux_milestones.include? check after demo
    if (self.data['event_type'] == 'event' && self.data['event_name'] == 'first_tutorial')
      HelloWorker.perform_in(1.minute, User.where(email: 'ben@raceyourself.com'), self.user)
      HelloWorker.perform_in(10.minute, User.where(email: 'ben@raceyourself.com'), self.user)
    end

  end

  def send_analytics

    event = case self.data["event_type"]
      when "event" then "E: " + self.data["event_name"]
      when "screen" then "S: " + self.data["screen_name"]
      else "unknown"
    end
    
    properties = pretty_segmentation_characteristics2

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

    # if the event concerns a challenge, and the action is not done by the challenge's creator, fire a new event
    # under the challenge creator's ID so we can track the challenge lifecycle under the original user
    challenge_event_name_mapping = {
      "open_challenge" => "recipient_open_challenge",
      "start_race" => "recipient_start_attempt",
      "complete_race" => "recipient_complete_attempt"
    }
    if ((challenge_event_name_mapping.keys.include?self.data["event_name"]) && (self.data.keys.include?("challenge_id"))) then
      c = Challenge.find(self.data["challenge_id"])
      return nil if c.creator_id == self.user_id  # no action if the creator attempts their own challenge
      e = self.dup
      e.user_id = c.creator_id  # something happened to the creator's challenge
      e.data["event_name"] = challenge_event_name_mapping[self.data["event_name"]]
      #TODO: add e.data["recipient_id"]
      e.save!
    end 

    logger.info("Event.send_analytics completed")

  end

end
