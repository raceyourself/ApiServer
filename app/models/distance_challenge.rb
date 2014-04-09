class DistanceChallenge < Challenge
  validates :distance, :time, presence: true
end
