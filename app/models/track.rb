class Track < UserDocument
  # fields
  field :name,    type: String
  field :type_id, type: Integer
  # indexes
  index type_id: Integer
  # validations
  validates :name, :type_id, presence: true
end