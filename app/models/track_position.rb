class TrackPosition < ActiveRecord::Base
  self.primary_keys = :device_id,:position_id 
end
