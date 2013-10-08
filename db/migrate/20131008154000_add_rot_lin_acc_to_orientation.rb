class AddRotLinAccToOrientation < ActiveRecord::Migration
  def change
    drop_table :orientation
    create_table :orientation
  end
end
