class AddDeletedAtInGameState < ActiveRecord::Migration
  def up
    add_column :games, :deleted_at, :datetime
  end
  def down
    remove_column :games, :deleted_at, :datetime
  end
end
