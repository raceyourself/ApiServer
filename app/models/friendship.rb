class Friendship 
  include ::Mongoid::Document
  include ::Mongoid::Timestamps::Updated
  include ::Mongoid::Paranoia

  # Custom id
  field :_id, type: String

  # Indirect polymorphic N:N relation
  belongs_to :identity, index: true
  belongs_to :friend, class_name: "Identity", polymorphic: true

  before_validation :generate_id
  before_upsert :set_updated_at

  def generate_id
    self._id ||= self.identity_id + self.friend_id
  end

  def serializable_hash(options = {})
    options = {
       include: :friend, 
       except: [:friend_id, :friend_type] 
    }.update(options)
    super(options)
  end

end
