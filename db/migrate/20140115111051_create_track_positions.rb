class CreateTrackPositions < ActiveRecord::Migration
  def change
    create_table :track_positions, {:id => false} do |t|
      t.integer :device_id, :null => false
      t.integer :position_id, :null => false
      t.integer :track_id, :null => false
      t.integer :state_id, :null => false
      t.integer :gps_ts, :limit => 8, :null => false
      t.integer :device_ts, :limit => 8, :null => false
      t.float :lng, :null => false
      t.float :lat, :null => false
      t.float :bearing
      t.float :corrected_bearing
      t.float :corrected_bearing_R
      t.float :corrected_bearing_significance
      t.float :speed, :null => false
      t.float :epe
      t.string :nmea

      t.timestamps
    end
    execute "ALTER TABLE track_positions ADD PRIMARY KEY (device_id,position_id)"
  end
end
