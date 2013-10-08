class Orientation < UserDocument
  # fields
  field :id,         type: Integer
  field :track_id,   type: Integer
  field :ts,         type: DateTime
  field :roll,       type: Float
  field :pitch,      type: Float
  field :yaw,        type: Float
     
  field :mag,        type: Array # [x,y,z] device co-ords
  field :acc,        type: Array # [x,y,z] device co-ords
  field :gyro,       type: Array # [x,y,z] device co-ords
  field :rot,        type: Array # [a,b,c,d] rotation vector
  field :linacc,     type: Array # [x,y,z] real-world co-ords
  # indexes
  index id: 1
  # validations
end
