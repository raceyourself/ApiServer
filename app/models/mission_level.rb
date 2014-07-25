class MissionLevel < ActiveRecord::Base
  self.primary_keys = :mission_id, :level

  belongs_to :mission
  belongs_to :challenge, :foreign_key => [:device_id, :challenge_id]
  has_many :claims, :class_name => 'MissionClaim', :foreign_key => [:mission_id, :level]

  def serializable_hash(options = {})
    options = {
    }.update(options || {})
    super(options)
  end
end
