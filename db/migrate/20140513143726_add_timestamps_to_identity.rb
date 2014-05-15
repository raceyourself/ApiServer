class AddTimestampsToIdentity < ActiveRecord::Migration
  def up
    add_column :identities, :created_at, :datetime, :null => false, :default => Time.at(0)
    add_column :identities, :updated_at, :datetime, :null => false, :default => Time.at(0)
  end
  def down
    remove_column :identities, :created_at, :datetime
    remove_column :identities, :updated_at, :datetime
  end
end
