class Track < ActiveRecord::Base
  include Concerns::UserRecord

  self.primary_keys = :device_id, :track_id
  has_many :positions, :foreign_key => [:device_id, :track_id], :dependent => :destroy

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    user.send_analytics
  end

end
