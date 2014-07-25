class AddDeletedAtToMatchedTrack < ActiveRecord::Migration
  def up
    add_column :matched_tracks, :deleted_at, :datetime
  end
  def down
    remove_column :matched_tracks, :deleted_at
  end
end
