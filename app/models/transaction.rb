class Transaction < UserDocument

  # key
  field :_id,           type: String 
  before_validation :generate_key
  
  # fields
  field :device_id,    type: Integer
  field :transaction_id,    type: Integer
  field :ts,           type: Integer
  field :transaction_type,  type: String
  field :transaction_calc,  type: String
  field :source_id,    type: String
  field :points_delta, type: Integer
  field :points_balance, type: Integer
  field :gems_delta, type: Integer, default: 0
  field :gems_balance, type: Integer, default: nil
  field :metabolism_delta, type: Float, default: 0
  field :metabolism_balance, type: Float, default: nil
  field :cash_delta,   type: Float
  field :currency,     type: String
  
  # indexes
  index({device_id: 1, transaction_id: 1}, {unique: true})
  
  # validations
  validates :device_id, :transaction_id, :transaction_type, :source_id, :points_balance, presence: true
  
  def generate_key
    composite = [device_id, transaction_id]
    self._id ||= composite.pack("L*").unpack("h*").first
  end
  
end
