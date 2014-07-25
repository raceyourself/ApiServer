class CounterChallenge < Challenge
  validates :counter, :value, presence: true

  def serializable_hash(options = {})
    options = {
      except: [:time, :duration, :pace]
    }.update(options || {})
    super(options)
  end
end
