class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
    self
  end
end
