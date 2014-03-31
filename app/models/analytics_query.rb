class AnalyticsQuery
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  # Primary key
  field :_id,               type: String
  # fields
  field :query,            type: Hash

  # validations
  validates :query, presence: true

end
