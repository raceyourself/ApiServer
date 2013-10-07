class AddSyncKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sync_key, :integer, null: false, default: 0

    add_index :users, :sync_key
  end
end
