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

  before_upsert :set_updated_at

  def user
    User.where(id: user_id).first
  end

end
