class Identity < ActiveRecord::Base
  self.primary_keys = :type, :uid
  # Bidirectional friend graph
  has_many :friendships, :foreign_key => [:identity_type, :identity_uid], :dependent => :destroy
  has_many :friends, :through => :friendships # TODO: Figure out how to support self.friends.clear
  has_many :invites, :foreign_key => [:identity_type, :identity_uid], :dependent => :nullify
  belongs_to :user # Optional

  def provider
    self.type.downcase.sub('identity', '')
  end

  def guid
    [type, uid].join('-')
  end

  def merge
    this = self
    begin
      o = self.class.find([self.type, self.uid])
      hash = self.attributes
      hash.delete('has_glass') if o.has_glass
      hash.delete('refreshed_at') if o.refreshed_at > self.refreshed_at
      hash.delete('user_id') unless hash['user_id'].present?
      cascade_touch = false
      cascade_touch = true if hash['has_glass'].present? && hash['has_glass'] != o.has_glass
      cascade_touch = true if hash['user_id'].present? && hash['user_id'] != o.user_id
      cascade_touch = true if hash['name'].present? && hash['name'] != o.name
      cascade_touch = true if hash['photo'].present? && hash['photo'] != o.photo
      # Update
      o.update!(hash)
      this = o
      if cascade_touch
        logger.info "Cascading changes to identity #{self.id}"
        # Touch friendships links of this identity so that the sync catches the change
        Friendship.where(:identity_type => this.type).where(:identity_uid => this.uid).update_all(updated_at: Time.now)
        Friendship.where(:friend_type => this.type).where(:friend_uid => this.uid).update_all(updated_at: Time.now)
      end
    rescue ActiveRecord::RecordNotFound => e
      # Insert
      self.save!
    end
    this
  end

  def serializable_hash(options = {})
    options = {
      methods: [:provider, :guid]
    }.update(options || {})
    super(options)
  end

end
