class MissionLevel < ActiveRecord::Base
  belongs_to :mission
  belongs_to :challenge, :foreign_key => [:device_id, :challenge_id]
end
