class Device
  include ::Mongoid::Document
  # Primary key
  field :_id,               type: Integer
  # fields
  field :manufacturer,      type: String
  field :model,             type: String
  field :glassfit_version,  type: String
  field :push_id,           type: String, default: nil

  # Foreign key
  field :user_id, type: Integer, default: nil

  auto_increment :_id

  # validations
  validates :manufacturer, :model, :glassfit_version, presence: true

  def merge
    # TODO: 
    self.upsert if self.valid?
  end

end
