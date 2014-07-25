class AddDeletedAtToClaim < ActiveRecord::Migration
  def up
    add_column :mission_claims, :deleted_at, :datetime
  end
  def down
    remove_column :mission_claims, :deleted_at
  end
end
