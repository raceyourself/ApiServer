class AddAuthenticationConstraint < ActiveRecord::Migration
  def up
    add_index :authentications, [:provider, :uid], unique: true
  end
  def down
    remove_index :authentications, [:provider, :uid]
  end
end
