class Identity 
  include ::Mongoid::Document
 
  # Fields
  field :has_glass, type: Boolean, default: false

  # Bidirectional friend graph
  has_many :friendships
  # May be linked to a registered user (nullable)
  field :user_id, type: Integer

  # Indexes
  index user_id: 1

  # Custom id generated polymorphically
  field :_id, type: String
  before_validation :generate_typed_id

  def generate_typed_id
    self._id ||= self._type.downcase.sub('identity', '') + generate_id()
  end

  def user
     User.where(id: user_id).first
  end

end
