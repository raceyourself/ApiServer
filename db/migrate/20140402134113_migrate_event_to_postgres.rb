class MigrateEventToPostgres < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.integer :ts, :limit => 8
      t.integer :version
      t.integer :device_id
      t.integer :session_id
      t.integer :user_id
      t.column  :data, :json

      t.timestamps
    end
  end
  def down
    drop_table 'events'
  end
end
