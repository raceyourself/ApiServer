class CreateMatchedTracks < ActiveRecord::Migration
  def up
    create_table :matched_tracks, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :device_id, :null => false
      t.integer :track_id, :null => false
    end
    execute 'ALTER TABLE matched_tracks ADD PRIMARY KEY (user_id,device_id,track_id);'
  end
  def down
    drop_table 'matched_tracks'
  end
end
