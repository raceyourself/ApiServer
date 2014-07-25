class CreateAccumulator < ActiveRecord::Migration
  def up
    create_table :accumulators, :id => false do |t|
      t.string :name, :null => false
      t.integer :user_id, :null => false
      t.float :value, :null => false, :default => 0
    end
    execute 'ALTER TABLE accumulators ADD PRIMARY KEY (name, user_id);'
  end
  def down
    drop_table :accumulators
  end
end
