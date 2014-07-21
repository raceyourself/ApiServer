class Track < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :track_id
  has_many :positions, :foreign_key => [:device_id, :track_id], :dependent => :destroy
  has_many :challenge_attempts, :foreign_key => [:device_id, :track_id], :dependent => :destroy

  after_commit :send_analytics, :on => [:create, :update]

  def guid
    (device_id << 32) + track_id 
  end

  def completed
    distance.present? && distance > 0 && time.present? && time > 0
  end

  def send_analytics
    user.send_analytics
  end

  def calculate_user_rank
    if distance.present? && distance > 1000 && time.present? && time > 60*1000
      pace = (time/1000/60)/(distance/1000) # min/km
      if pace >= 3 && pace <= 15 # Ignore invalid values
        rank = [15 - pace.to_i, 1].max
        user = self.user
        if user.rank < rank
          user.update!(rank: rank)
        end
      end
    end
  end

  def update_user_counters
    Accumulator.add('distance_travelled', user.id, distance) 
    Accumulator.add('time_travelled', user.id, time) 
    Accumulator.add('tracks_completed', user.id, 1)
    
      # Calculate total up/down altitude
      origin = nil
      peak = nil
      trough = nil
      positions.each do |position|
        altitude = position.alt
        next unless altitude
        origin = altitude unless origin
        peak = altitude unless peak 
        trough = altitude unless trough

        peak = altitude if altitude > peak
        trough = altitude if altitude < trough
      end

    if origin && peak && trough
      Accumulator.add('height_ascended', user.id, (peak - origin)) 
      Accumulator.add('height_descended', user.id, (origin - trough)) 
    end
  end

  def merge_delete(user)
    # Allow user to delete
    device = Device.find(device_id)
    delete if (device.present? && device.user_id = user.id)
  end

  def self.before_merge(previous, current)
    if !previous.completed && current.completed

      logger.info "Track #{current.id} was completed"
      current.calculate_user_rank
      current.update_user_counters

    end
  end
end
