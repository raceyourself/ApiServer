class Friend < UserDocument
  # fields
  field :friend_id, type: Integer
  # validations
  validates :friend_id, presence: true
end