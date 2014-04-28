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
    # TODO: Improve performance:
    #       Do  a) update! || save for things likely to always exist
    #       and b) create! || update for things likely to not exist
    #       Surround data_controller::import with a transaction
    # NOTE: update_all should bypass object instantiation
    #       activerecord-import could work similarly for inserts
    #       data validation is the only problem
    hash = self.attributes.except('created_at', 'deleted_at', 'updated_at')
    key = hash.extract!(*self.class.primary_key)
    begin
      o = self.class.find(key.values)
      # Update
      o.updated_at = Time.now
      o.update!(hash)
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
