class Track < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :track_id
  has_many :positions, :foreign_key => [:device_id, :track_id], :dependent => :destroy
  has_many :challenge_attempts, :foreign_key => [:device_id, :track_id], :dependent => :destroy

  after_commit :send_analytics, :on => [:create, :update]
  after_commit :calculate_rank, :on => [:create, :update]

  def guid
    (device_id << 32) + track_id 
  end

  def send_analytics
    user.send_analytics
  end

  def calculate_rank
    if distance.present? && distance > 0 && time.present? && time > 0
      pace = (time/1000/60)/(distance/1000) # min/km
      rank = [15 - pace.to_i, 1].max
      user = self.user
      if user.rank < rank
        user.update!(rank: rank)
      end
    end
  end

  def merge_delete(user)
    # Allow user to delete
    device = Device.find(device_id)
    delete if (device.present? && device.user_id = user.id)
  end

end
