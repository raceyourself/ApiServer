class CreateMission < ActiveRecord::Migration
  def up
    create_table :missions, :id => false do |t|
      t.string :id, :null => false
      t.timestamps
      t.datetime :deleted_at
    end
    execute 'ALTER TABLE missions ADD PRIMARY KEY (id);'
    create_table :mission_levels, :id => false do |t|
      t.string :mission_id, :null => false
      t.integer :level, :null => false
      t.integer :device_id, :null => false
      t.integer :challenge_id, :null => false
    end
    execute 'ALTER TABLE mission_levels ADD PRIMARY KEY (mission_id,level);'
  end
  def down
    drop_table :missions
    drop_table :mission_levels
  end
end
