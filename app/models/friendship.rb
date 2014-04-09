class Friendship < ActiveRecord::Base
  self.primary_keys = :identity_type, :identity_uid, :friend_type, :friend_uid

  belongs_to :identity, :foreign_key => [:identity_type, :identity_uid]
  belongs_to :friend, :foreign_key => [:friend_type, :friend_uid], :class_name => Identity

  def serializable_hash(options = {})
    options = {
       include: :friend, 
       except: [:friend_type, :friend_uid] 
    }.update(options)
    super(options)
  end

end
