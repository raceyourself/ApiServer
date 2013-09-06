class Device < UserDocument
  # fields
  field :manufacturer, type: String
  field :model, type: String
  field :glassfit_version, type: String
  # indexes

  # validations
  validates :manufacturer, :model, :glassfit_version, presence: true
end