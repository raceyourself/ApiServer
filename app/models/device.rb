class Device < ActiveRecord::Base
  include Concerns::UserRecord
  # user association may be null until claimed

  def pretty_segmentation_characteristics
    d = {
      "Device Manufacturer" => self.manufacturer,
      "Device Model" => self.model
    }
  end

  def merge
    if self.id
      device = Device.find(self.id)
      if device
        device.push_id = self.push_id
        device.user_id = self.user_id
      end
    end
    device = self unless device
    device.save!
    device
  end

  after_commit :send_analytics, :on => [:create, :update]

  def send_analytics
    defined? user do user.send_analytics end
  end

end
