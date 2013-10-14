class Position < UserDocument
  # fields
  field :track_id,  type: Integer
  field :state_id,  type: Integer
  field :gps_ts,    type: Integer 
  field :device_ts, type: Integer
  field :lng,       type: Float
  field :lat,       type: Float
  field :alt,       type: Float
  field :bearing,   type: Float
  field :corrected_bearing,                type: Float
  field :corrected_bearing_R,              type: Float
  field :corrected_bearing_significance,   type: Float
  field :speed,     type: Float
  field :epe,       type: Float
  field :nmea,      type: String
  # indexes
  index track_id: 1
  index state_id: 1
  index nmea: 1
  # validations
  validates :track_id, :state_id, :gps_ts, :lng, :lat, :alt, :bearing, presence: true
end
