class Identity < ActiveRecord::Base
  self.primary_keys = :type, :uid
  # Bidirectional friend graph
  has_many :friendships, :foreign_key => [:identity_type, :identity_uid], :dependent => :destroy
  has_many :friends, :through => :friendships # TODO: Figure out how to support self.friends.clear
  belongs_to :user # Optional

  def provider
    self.type.downcase.sub('identity', '')
  end

  def merge
    begin
      o = self.class.find([self.type, self.uid])
      # Update
      o.update!(self.attributes)
    rescue ActiveRecord::RecordNotFound => e
      # Insert
      self.save!
    end
  end

  def serializable_hash(options = {})
    options = {
      methods: :provider
    }.update(options)
    super(options)
  end

end
