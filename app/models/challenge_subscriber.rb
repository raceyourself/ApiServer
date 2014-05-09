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
    # Acts as a decorated challenge
    options = {
      include: :challenge,
      except: [:id, :challenge_id, :user_id],
      methods: [:friends]
    }.update(options)
    hash = super(options)
    hash.merge!(hash.delete('challenge')) if hash
    hash
  end

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    user.send_analytics
  end

end
