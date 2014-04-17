class AddActivityToGame < ActiveRecord::Migration
  def up
    add_column :games, :activity, :string
  end
  def down
    remove_column :games, :activity, :string
  end
end
