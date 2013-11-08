class DistanceChallenge < Challenge
  # fields
  field :distance, type: Integer # meters
  field :time,     type: Integer # seconds

  validates :distance, :time, presence: true

  def type
    "distance"
  end
end
