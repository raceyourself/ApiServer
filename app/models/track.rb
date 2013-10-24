class Track < UserDocument
  # fields
  field :device_id,     type: Integer
  field :track_id,      type: Integer
  field :track_name,    type: String
  field :track_type_id, type: Integer
  field :ts,            type: Integer
  # indexes
  index({device_id: 1, track_id: 1}, {unique: true})
  index track_type_id: 1
  index ts: 1
  # validations
  validates :device_id, :track_id, :track_name, :track_type_id, :ts, presence: true
end
