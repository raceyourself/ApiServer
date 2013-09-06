class Transaction < UserDocument
  # fields
  field :ts, type: DateTime
  field :source_id, type: Integer
  field :product_id, type: Integer
  field :points_delta, type: Integer
  field :cash_delta, type: Float
  field :currency, type: String
  # indexes
  index source_id: 1
  index product_id: 1
  # validations
  validates :source_id, :product_id, presence: true
end