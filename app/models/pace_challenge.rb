class PaceChallenge < Challenge
  validates :pace, :distance, presence: true
end
