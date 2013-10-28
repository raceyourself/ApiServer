class Notification < UserDocument
  # fields
  field :read,      type: Boolean, default: false
  field :message,   type: String # JSON 
  # validations
  validates :read, :message, presence: true
end
