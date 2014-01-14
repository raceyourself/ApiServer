class Event < UserDocument
  # default key
 
  # fields
  field :ts,            type: Integer
  field :version,       type: Integer
  field :device_id,     type: Integer
  field :session_id,    type: Integer
  field :data,          type: Hash
  
  # indexes
  index({ts: -1})
  
  # validations
  validates :ts, :version, :device_id, :session_id, :data, presence: true
  
end
