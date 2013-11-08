class Challenge
  include ::Mongoid::Document
  include ::Mongoid::Timestamps::Updated
  include ::Mongoid::Paranoia

  # May be linked to a registered user (nullable)
  field :creator_id, type: Integer

  # Embed foreign keys 
  has_and_belongs_to_many :attempts, class_name: "Track", inverse_of: nil

  # fields
  field :start_time,    type: DateTime, default: nil
  field :stop_time,     type: DateTime, default: nil
  field :location,      type: Array, default: nil
  field :public,        type: Boolean, default: false
  # indexes
  # now.between(start, stop) and geo_near
  
  before_upsert :set_updated_at

  # validations
  validates :public, presence: true

  def creator
    User.where(id: creator_id).first
  end
end
