class ChallengeAttempt < ActiveRecord::Base
  belongs_to :challenge
  belongs_to :track, :foreign_key => [:device_id, :track_id]
end
