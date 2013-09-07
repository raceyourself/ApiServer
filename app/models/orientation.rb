class Orientation < UserDocument
  # fields
  field :ts,    type: DateTime
  field :roll,  type: Float
  field :pitch, type: Float
  field :yaw,   type: Float

  field :mag,   type: Array # [x,y,z]
  field :acc,   type: Array # [x,y,z]
  field :gyro,  type: Array # [x,y,z]
  # indexes
  # validations
end