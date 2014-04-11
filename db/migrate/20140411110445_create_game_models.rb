class CreateGameModels < ActiveRecord::Migration
  def up
    create_table :games, :id => false do |t|
      t.string  :id,              :null => false
      t.string  :name,            :null => false
      t.string  :description,     :null => false
      t.integer :tier,            :null => false
      t.integer :price_in_points, :null => false
      t.integer :price_in_gems,   :null => false
      t.string  :scene_name,      :null => false
      t.string  :type,            :null => false
    end
    execute 'ALTER TABLE games ADD PRIMARY KEY (id);'
    create_table :game_states do |t|
      t.boolean :locked
      t.boolean :enabled

      t.string :game_id, :null => false
      t.integer :group_id
      t.integer :user_id
      t.index   :game_id
      
      t.timestamps
    end
    create_table :menu_items do |t|
      t.string  :icon,    :null => false
      t.integer :column,  :null => false
      t.integer :row,     :null => false

      t.string :game_id, :null => false
      t.index   :game_id
    end
  end
  def down
    drop_table 'games'
    drop_table 'game_states'
    drop_table 'menu_items'
  end
end
