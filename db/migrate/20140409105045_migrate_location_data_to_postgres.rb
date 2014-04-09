class MigrateLocationDataToPostgres < ActiveRecord::Migration
  def up
    create_table :tracks, :id => false do |t|
      t.integer  :device_id, :null => false
      t.integer  :track_id,  :null => false
      t.string   :track_name
      t.integer  :ts,        :length => 8, :null => false
      t.boolean  :public,    :default => false
      t.float    :distance
      t.integer  :time
      # user record fields:
      t.integer  :user_id,    :null => false
      t.timestamps
      t.datetime :deleted_at
      t.index    :user_id
    end
    execute 'ALTER TABLE tracks ADD PRIMARY KEY (device_id,track_id);'
    create_table :positions, :id => false do |t|
      t.integer :device_id, :null => false
      t.integer :position_id, :null => false
      t.integer :track_id, :null => false
      t.integer :state_id, :null => false
      t.integer :gps_ts, :length => 8, :null => false
      t.integer :device_ts, :length => 8, :null => false
      t.float   :lng, :null => false
      t.float   :lat, :null=> false
      t.float   :alt, :null => false
      t.float   :bearing, :null => false
      t.float   :corrected_bearing
      t.float   :corrected_bearing_R
      t.float   :corrected_bearing_significance
      t.float   :speed
      t.float   :epe
      t.string  :nmea
      # user record fields:
      t.integer  :user_id,    :null => false
      t.timestamps
      t.datetime :deleted_at
      t.index    :user_id

      t.index    [:device_id, :track_id] # Foreign key
    end
    execute 'ALTER TABLE positions ADD PRIMARY KEY (device_id,position_id);'
  end
  def down
    drop_table 'tracks'
    drop_table 'positions'
  end
end
