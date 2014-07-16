class Mission < ActiveRecord::Base
  acts_as_paranoid
  has_many :levels, :class_name => "MissionLevel"

  def serializable_hash(options = {})
    options = {
      include: :levels
    }.update(options || {})
    super(options)
  end

end
