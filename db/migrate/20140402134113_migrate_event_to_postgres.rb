class MigrateEventToPostgres < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.integer :ts,         :limit => 8, :null => false
      t.integer :version,    :null => false
      t.integer :device_id,  :null => false
      t.integer :session_id, :null => false
      t.integer :user_id,    :null => false
      t.column  :data,       :json, :null => false

      t.timestamps
    end
  end
  def down
    drop_table 'events'
  end
end
