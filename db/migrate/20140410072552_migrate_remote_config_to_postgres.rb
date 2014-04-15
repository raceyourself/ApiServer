class MigrateRemoteConfigToPostgres < ActiveRecord::Migration
  def up
    create_table :configurations do |t|
      t.string  :type,                 :null => false
      t.column  :configuration, :json, :null => false
      t.integer :group_id
      t.timestamps
    end
  end
  def down
    drop_table 'configurations'
  end
end
