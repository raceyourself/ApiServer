class DurationChallenge < Challenge
  validates :duration, :distance, presence: true
end
