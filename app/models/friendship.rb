class Friendship 
  include ::Mongoid::Document

  # Custom id
  field :_id, type: String

  # Indirect polymorphic N:N relation
  belongs_to :identity, index: true
  belongs_to :friend, class_name: "Identity", polymorphic: true

  before_validation :generate_id

  def generate_id
    self._id ||= self.identity_id + self.friend_id
  end

end
