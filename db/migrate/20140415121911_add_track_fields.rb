class AddTrackFields < ActiveRecord::Migration
  def up
    add_column :tracks, :track_type_id, :integer, :null => false, :default => 1
  end
  def down
    remove_column :tracks, :track_type_id
  end
end
