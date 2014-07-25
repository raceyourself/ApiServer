class MatchedTrack < ActiveRecord::Base
  include Concerns::UserRecord

  def merge
    self.save!
  end
end
