class DistanceChallenge < Challenge
  validates :distance, :time, presence: true
  
  def serializable_hash(options = {})
    options = {
      except: [:duration, :pace, :counter, :value]
    }.update(options || {})
    super(options)
  end
end
