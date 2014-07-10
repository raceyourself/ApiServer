class Track < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :track_id
  has_many :positions, :foreign_key => [:device_id, :track_id], :dependent => :destroy
  has_many :challenge_attempts, :foreign_key => [:device_id, :track_id], :dependent => :destroy

  after_commit :send_analytics, :on => [:create, :update]

  def guid
    (device_id << 32) + track_id 
  end

  def send_analytics
    user.send_analytics
  end

  def merge_delete(user)
    # Allow user to delete
    device = Device.find(device_id)
    delete if (device.present? && device.user_id = user.id)
  end

end
