class UserDocument
  include ::Mongoid::Document
  include ::Mongoid::Timestamps::Updated
  include ::Mongoid::Paranoia
  # fields
  field :user_id, type: Integer
  # indexes
  index user_id: 1
  # validations
  validates :user_id, presence: true

  def user
    User.where(id: user_id).first
  end

end
