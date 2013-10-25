class Orientation < UserDocument
  # key
  field :_id,        type: String
  before_validation :generate_key
  # fields
  field :orientation_id, type: Integer
  field :device_id,  type: Integer
  field :track_id,   type: Integer
  field :ts,         type: Integer
  field :roll,       type: Float
  field :pitch,      type: Float
  field :yaw,        type: Float
     
  field :mag_x,        type: Float # [x,y,z] device co-ords
  field :mag_y,        type: Float # [x,y,z] device co-ords
  field :mag_z,        type: Float # [x,y,z] device co-ords
  field :acc_x,        type: Float # [x,y,z] device co-ords
  field :acc_y,        type: Float # [x,y,z] device co-ords
  field :acc_z,        type: Float # [x,y,z] device co-ords
  field :gyro_x,       type: Float # [x,y,z] device co-ords
  field :gyro_y,       type: Float # [x,y,z] device co-ords
  field :gyro_z,       type: Float # [x,y,z] device co-ords
  field :rot_a,        type: Float # [a,b,c,d] rotation vector
  field :rot_b,        type: Float # [a,b,c,d] rotation vector
  field :rot_c,        type: Float # [a,b,c,d] rotation vector
  field :rot_d,        type: Float # [a,b,c,d] rotation vector
  field :linacc_x,     type: Float # [x,y,z] real-world co-ords
  field :linacc_y,     type: Float # [x,y,z] real-world co-ords
  field :linacc_z,     type: Float # [x,y,z] real-world co-ords
  # indexes
  index({device_id: 1, track_id: 1, orientation_id: 1}, {unique: true})
  index ts: 1
  # validations

  def generate_key
    composite = [device_id, orientation_id]
    self._id ||= composite.pack("L*").unpack("h*").first
  end
end
