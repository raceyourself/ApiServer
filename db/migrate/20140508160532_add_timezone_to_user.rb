class AddTimezoneToUser < ActiveRecord::Migration
  def up
    add_column :users, :timezone, :integer
  end
  def down
    remove_column :users, :timezone
  end
end
