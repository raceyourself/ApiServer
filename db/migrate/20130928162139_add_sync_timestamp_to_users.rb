class AddSyncTimestampToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sync_timestamp, :datetime
  end
end
