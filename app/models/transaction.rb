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
  field :points_delta, type: Integer, default: 0
  field :points_balance, type: Integer, default: 0
  field :gems_delta, type: Integer, default: 0
  field :gems_balance, type: Integer, default: 0
  field :metabolism_delta, type: Float, default: 0
  field :metabolism_balance, type: Float, default: 0
  field :cash_delta,   type: Float, default: 0
  field :currency,     type: String
  
  # indexes
  index({device_id: 1, transaction_id: 1}) #, {unique: true})
  index({user_id: 1, ts: -1})
  
  # validations
  validates :device_id, :transaction_id, :transaction_type, :source_id, :points_delta, :gems_delta, :metabolism_delta, :cash_delta, presence: true
  
  def generate_key
    composite = [device_id, transaction_id]
    self._id ||= composite.pack("L*").unpack("h*").first
  end
  
  def self.import(transactions, user)
    logger.info "Importing " + transactions.length.to_s + " transactions for user " + user.id.to_s
    transactions = transactions.sort_by { |value| value[:ts]  }
    # NOTE: We assume that there is only one sync concurrently per user. May work incorrectly otherwise.
    latest = user.latest_transaction
    unless latest
      latest = Transaction.new()
    end
    latest.points_balance ||= 0
    latest.gems_balance ||= 0
    latest.metabolism_balance ||= 0
    warnings = Hash.new(0)
    transactions.each do |data|
      transaction = user.transactions.new(data)
      
      # Recalculate balance from deltas
      points_balance = latest.points_balance + transaction.points_delta
      gems_balance = latest.gems_balance + transaction.gems_delta
      metabolism_balance = latest.metabolism_balance + transaction.metabolism_delta
      
      warnings[:points_mismatch] += 1 if points_balance != transaction.points_balance
      warnings[:gems_mismatch] += 1 if gems_balance != transaction.gems_balance
      warnings[:metabolism_mismatch] += 1 if metabolism_balance.to_i != transaction.metabolism_balance.to_i

      transaction.points_balance = points_balance
      transaction.gems_balance = gems_balance
      transaction.metabolism_balance = metabolism_balance
      transaction.save!
      latest = transaction
    end

    logger.info "WARNING: " + warnings.to_s + " for user " + user.id.to_s unless warnings.empty?
  end
  
end
