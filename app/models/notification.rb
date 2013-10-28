class Notification < UserDocument
  # fields
  field :read,      type: Boolean, default: false
  field :message,   type: Hash # JSON, TODO: Polymorphism? 
  # validations
  validates :read, :message, presence: true
end
