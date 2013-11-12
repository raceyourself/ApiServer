class DurationChallenge < Challenge
  # fields
  field :duration,   type: Integer # seconds
  field :distance,   type: Integer # meters

  validates :duration, :distance, presence: true

end
