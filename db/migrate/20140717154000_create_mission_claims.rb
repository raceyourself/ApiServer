class CreateMissionClaims < ActiveRecord::Migration
  def up
    create_table :mission_claims, :id => false do |t|
      t.string :mission_id, :null => false
      t.integer :level, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    execute 'ALTER TABLE mission_claims ADD PRIMARY KEY (mission_id,level,user_id);'
  end
  def down
    drop_table :mission_claims
  end
end
