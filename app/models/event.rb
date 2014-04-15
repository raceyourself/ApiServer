class Event < ActiveRecord::Base
  belongs_to :user

  def merge
    self.save!
  end
end
