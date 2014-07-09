class AddDeletedAtToDevice < ActiveRecord::Migration
  def up
    add_column :devices, :deleted_at, :datetime
  end
  def down
    remove_column :devices, :deleted_at
  end
end
