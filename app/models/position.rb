class Position < UserDocument
  # fields
  field :track_id,  type: Integer
  field :state_id,  type: Integer
  field :ts,        type: DateTime
  field :lng,       type: Float
  field :lat,       type: Float
  field :alt,       type: Float
  field :bearing,   type: Float
  field :epe,       type: Float
  field :nmea,      type: String
  # indexes
  index track_id: 1
  index state_id: 1
  index nmea: 1
  # validations
  validates :track_id, :state_id, :ts, :lng, :lat, :alt, :bearing, presence: true
end