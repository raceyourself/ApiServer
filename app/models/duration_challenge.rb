class DurationChallenge < Challenge
  validates :duration, :distance, presence: true
  
  def serializable_hash(options = {})
    options = {
      except: [:time, :pace]
    }.update(options || {})
    super(options)
  end
end
