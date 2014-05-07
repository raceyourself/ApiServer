class AlterChallenge < ActiveRecord::Migration
  def up
    add_column :challenges, :name, :string
    add_column :challenges, :description, :text 
    add_column :challenges, :points_awarded, :integer, :null => false, :default => 0
    add_column :challenges, :prize, :string
  end
  def down
    remove_column :challenges, :points_awarded
    remove_column :challenges, :description
    remove_column :challenges, :name
    remove_column :challenges, :prize
  end
end
