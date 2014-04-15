class Track < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :track_id
  has_many :positions, :foreign_key => [:device_id, :track_id]
end
