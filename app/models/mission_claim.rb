class MissionClaim < ActiveRecord::Base
  belongs_to :mission_level, :foreign_key => [:mission_id, :level]
  belongs_to :user
end
