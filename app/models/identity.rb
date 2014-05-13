class Identity < ActiveRecord::Base
  self.primary_keys = :type, :uid
  # Bidirectional friend graph
  has_many :friendships, :foreign_key => [:identity_type, :identity_uid], :dependent => :destroy
  has_many :friends, :through => :friendships # TODO: Figure out how to support self.friends.clear
  has_many :invites, :foreign_key => [:identity_type, :identity_uid]
  belongs_to :user # Optional

  def provider
    self.type.downcase.sub('identity', '')
  end

  def merge
    this = self
    begin
      o = self.class.find([self.type, self.uid])
      hash = self.attributes
      hash.delete('has_glass') if o.has_glass
      hash.delete('user_id') if o.user_id != nil
      hash['updated_at'] = Time.now
      # Update
      o.update!(hash)
      this = o
    rescue ActiveRecord::RecordNotFound => e
      # Insert
      self.updated_at = Time.now
      self.save!
    end
    this
  end

  def serializable_hash(options = {})
    options = {
      methods: :provider
    }.update(options)
    super(options)
  end

end
