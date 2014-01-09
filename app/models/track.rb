class Track < UserDocument
  # key
  field :_id,           type: String 
  before_validation :generate_key 

  # fields
  field :device_id,     type: Integer
  field :track_id,      type: Integer
  field :track_name,    type: String
  field :track_type_id, type: Integer
  field :ts,            type: Integer
  field :public,        type: Boolean, default: false 
  field :distance, 	type: Float
  field :time, 		type: Integer

  # indexes
  index({device_id: 1, track_id: 1}, {unique: true})
  index track_type_id: 1
  index ts: 1

  # validations
  validates :device_id, :track_id, :track_name, :track_type_id, :ts, presence: true

  def generate_key
    composite = [device_id, track_id]
    self._id ||= composite.pack("L*").unpack("h*").first
  end

  def positions
     Position.where(device_id: device_id, track_id: track_id)
  end
end
