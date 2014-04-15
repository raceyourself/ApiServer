class AddDeletedAtInGameState < ActiveRecord::Migration
  def up
    add_column :game_states, :deleted_at, :datetime
  end
  def down
    remove_column :game_states, :deleted_at, :datetime
  end
end
