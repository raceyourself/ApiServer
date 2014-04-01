class AnalyticsView
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  # Primary key
  field :_id,               type: String
  # fields
  field :script,            type: String

  # validations
  validates :script, presence: true

end
