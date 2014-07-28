class Friendship < ActiveRecord::Base
  acts_as_paranoid

  self.primary_keys = :identity_type, :identity_uid, :friend_type, :friend_uid

  belongs_to :identity, :foreign_key => [:identity_type, :identity_uid]
  belongs_to :friend, :foreign_key => [:friend_type, :friend_uid], :class_name => Identity

  def guid
    [identity_type, identity_uid, friend_type, friend_uid].join('-')
  end

  def merge
    hash = self.attributes.except('created_at', 'deleted_at', 'updated_at')
    key = hash.extract!(*self.class.primary_key)
    this = self
    begin
      o = self.class.with_deleted.find(key.values)
      # Use old updated_at unless restoring. Identity will cascade touch when needed.
      unless o.destroyed?
        hash['updated_at'] = o.updated_at
      else
        hash['updated_at'] = Time.now
      end
      hash['deleted_at'] = nil
      o.update!(hash)
      this = o
    rescue ActiveRecord::RecordNotFound => e
      # Insert
      self.save!
    end
    this
  end

  def serializable_hash(options = {})
    options = {
       include: :friend, 
       except: [:friend_type, :friend_uid],
       methods: :guid
    }.update(options || {})
    super(options)
  end

end
