class MissionClaim < ActiveRecord::Base
  acts_as_paranoid
  self.primary_keys = :mission_id, :level, :user_id

  belongs_to :mission_level, :foreign_key => [:mission_id, :level]
  belongs_to :user

  def merge
    zombie = MissionClaim.only_deleted.where(mission_id: mission_id, level: level, user_id: user_id).first
    zombie.really_destroy! if zombie
    self.save 
  end
end
