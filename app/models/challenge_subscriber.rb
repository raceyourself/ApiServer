class ChallengeSubscriber < ActiveRecord::Base
  belongs_to :challenge
  belongs_to :user

  def friends
    challenge.racer_ids & user.registered_friend_ids
  end

  def serializable_hash(options = {})
    options = {
      except: [:challenge_id, :user_id],
      methods: :friends
    }.update(options)
    super(options)
  end
end
