class Notification < ActiveRecord::Base
  include Concerns::UserRecord

  def merge
    this = self.class.find(self.id)
    this.update!(read: self.read)
    this
  end
end
