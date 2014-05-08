class ChallengeSubscriber < ActiveRecord::Base
  self.primary_keys = :challenge_id, :user_id
  belongs_to :challenge
  belongs_to :user

  def self.with_deleted
    all    
  end

  def friends
    challenge.racer_ids & user.registered_friend_ids
  end

  def serializable_hash(options = {})
    options = {
      except: [:id, :user_id],
      methods: [:friends]
    }.update(options)
    hash = super(options)
    hash['id'] = hash.delete('challenge_id') if hash
    hash
  end
end
