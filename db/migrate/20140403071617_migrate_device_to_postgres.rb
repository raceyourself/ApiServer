class MigrateDeviceToPostgres < ActiveRecord::Migration
  def up
    create_table :devices do |t|
      t.string :manufacturer,     :null => false
      t.string :model,            :null => false
      t.string :glassfit_version, :null => false
      t.string :push_id

      # Foreign key, may be null
      t.integer :user_id

      t.timestamps
    end
  end
  def down
    drop_table 'devices'
  end
end
