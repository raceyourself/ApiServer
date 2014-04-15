class AddUserIdToRemoteConfig < ActiveRecord::Migration
  def up
    add_column :configurations, :user_id, :integer
  end
  def down
    remove_column :configurations, :user_id, :integer
  end
end
