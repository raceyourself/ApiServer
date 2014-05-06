class AddUserProfile < ActiveRecord::Migration
  def up
    add_column :users, :profile, :json, :default => {}
  end
  def down
    remove_column :users, :profile
  end
end
