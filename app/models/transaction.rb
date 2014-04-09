class Transaction < ActiveRecord::Base
  include Concerns:UserRecord

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
