class PaceChallenge < Challenge
  # fields
  field :pace,       type: Integer # seconds/km
  field :distance,   type: Integer # meters

  validates :pace, :distance, presence: true

end
