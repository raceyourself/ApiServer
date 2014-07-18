class MissionClaim < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :mission_level, :foreign_key => [:mission_id, :level]
  belongs_to :user
end
