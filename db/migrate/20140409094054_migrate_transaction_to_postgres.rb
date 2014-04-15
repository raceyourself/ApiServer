class MigrateTransactionToPostgres < ActiveRecord::Migration
  def up
    create_table :transactions, :id => false do |t|
      t.integer  :device_id,          :null => false
      t.integer  :transaction_id,     :null => false
      t.integer  :ts,                 :null => false  
      t.string   :transaction_type,   :null => false 
      t.string   :transaction_calc,   :null => false  
      t.string   :source_id,          :null => false 
      t.integer  :points_delta,       :null => false, :default => 0
      t.integer  :points_balance,     :null => false, :default => 0
      t.integer  :gems_delta,         :null => false, :default => 0
      t.integer  :gems_balance,       :null => false, :default => 0
      t.float    :metabolism_delta,   :null => false, :default => 0
      t.float    :metabolism_balance, :null => false, :default => 0
      t.float    :cash_delta,         :null => false, :default => 0
      t.string   :currency
      # user record fields:
      t.integer  :user_id,            :null => false
      t.timestamps
      t.datetime :deleted_at
      t.index    :user_id

      t.index    :ts
    end
    execute 'ALTER TABLE transactions ADD PRIMARY KEY (device_id, transaction_id);'
  end
  def down
    drop_table 'transactions'
  end
end
