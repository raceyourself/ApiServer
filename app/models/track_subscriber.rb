class TrackSubscriber < ActiveRecord::Base
  self.primary_keys = :device_id, :track_id, :user_id
  belongs_to :track, :foreign_key => [:device_id, :track_id]
  belongs_to :user

  def self.with_deleted
    all    
  end

end
