class CreateTrackSubscriber < ActiveRecord::Migration
  def up
    create_table :track_subscribers, id: false do |t|
      t.integer :device_id, :null => false
      t.integer :track_id, :null => false
      t.integer :user_id, :null => false
    end
    execute 'ALTER TABLE track_subscribers ADD PRIMARY KEY (device_id, track_id, user_id)' 
  end
  def down
    drop_table :track_subscribers
  end
end
