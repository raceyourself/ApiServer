class Position < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :position_id
  belongs_to :track, :foreign_key => [:device_id, :track_id]

  def guid
    (device_id << 32) + position_id
  end
end
