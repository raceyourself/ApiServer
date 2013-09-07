class UserDocument
  include ::Mongoid::Document
  # fields
  field :user_id, type: Integer
  field :sync_key, type: String
  # indexes
  index user_id: 1
  # validations
  validates :user_id, presence: true
end