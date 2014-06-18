class Challenge < ActiveRecord::Base
  acts_as_paranoid
  has_one :creator
  has_many :challenge_attempts, :dependent => :destroy
  has_many :attempts, :through => :challenge_attempts, :source => :track
  has_many :challenge_subscribers, :dependent => :destroy
  has_many :subscribers, :through => :challenge_subscribers, :source => :user
  has_many :challenge_racers, -> { where accepted: true }, :class_name => 'ChallengeSubscriber'
  has_many :racers, :through => :challenge_racers, :source => :user 

  before_save :default_values

  def pretty_segmentation_characteristics
    d = {
      "Challenge Type" => self.type,
      "Challenge Duration" => self.duration,
      "Challenge Distance" => self.distance,
      "Challenge Time" => self.time,
      "Challenge Pace" => self.pace
    }
  end


  def challenge_type
    self.type.downcase.sub('challenge', '')
  end

  def serializable_hash(options = {})
    options = {
      except: :attempt_ids,
      include: {
        attempts: { only: [ :device_id, :track_id, :user_id ] }
      }
    }.update(options || {})
    hash = super(options)
    hash['type'] = challenge_type() if hash
    hash
  end

  def self.build(challenge)
    full_type = challenge[:type].capitalize + 'Challenge'
    challenge[:type] = full_type
    c = Challenge.create!(challenge.except(:attempts))
    if challenge[:attempts]
      attempts = challenge[:attempts]
      attempts.each do |attempt|
        track = Track.where(device_id: attempt[:device_id], track_id: attempt[:track_id]).first
        c.attempts << track
      end
    end
    return c
  end

  def merge
    existing = Challenge.where(id: self.id).first
    this = self
    unless existing.nil?
      # Add subscriber?
      # Change details if current_user == creator_id 
      this = existing
    end
    this
  end

  def default_values
    self.start_time ||= Time.now
    self.stop_time ||= 48.hours.from_now
  end
end
