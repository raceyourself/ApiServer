class RenameIdTimestampColumn < ActiveRecord::Migration
  def up
    rename_column :identities, :updated_at, :refreshed_at
    remove_column :identities, :created_at
  end
  def down
    rename_column :identities, :refreshed_at, :updated_at
    add_column :identities, :created_at, :datetime, :null => false, :default => Time.at(0)
  end
end
