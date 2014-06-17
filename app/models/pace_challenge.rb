class PaceChallenge < Challenge
  validates :pace, :distance, presence: true

  def serializable_hash(options = {})
    options = {
      except: [:time, :duration]
    }.update(options || {})
    super(options)
  end
end
