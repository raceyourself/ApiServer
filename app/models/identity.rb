class Identity < ActiveRecord::Base
  self.primary_keys = :type, :uid
  # Bidirectional friend graph
  has_many :friendships, :foreign_key => [:identity_type, :identity_uid], :dependent => :destroy
  has_many :friends, :through => :friendships # TODO: Figure out how to support self.friends.clear 

  def provider
    self.type.downcase.sub('identity', '')
  end

  def serializable_hash(options = {})
    options = {
      methods: :provider
    }.update(options)
    super(options)
  end

  def merge
    return unless self.valid?
    existing = Identity.where(id: self.id).first
    unless existing.nil?
      self.user_id = existing.user_id
      self.has_glass = existing.has_glass
    end
    self.upsert
  end
end
