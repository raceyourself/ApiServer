class AnalyticsQuery
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  # Primary key
  field :_id,               type: String
  # fields
  field :sql,               type: String

  # validations
  validates :sql, presence: true

end
