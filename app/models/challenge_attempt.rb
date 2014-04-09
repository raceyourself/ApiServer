class ChallengeAttempt < ActiveRecord::Base
  belongs_to :challenge
  belongs_to :track
end
