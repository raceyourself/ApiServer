class ChallengeAttempt < ActiveRecord::Base
  belongs_to :challenge, :foreign_key => [:track_device_id, :challenge_id]
  belongs_to :track, :foreign_key => [:challenge_device_id, :track_id]
end
