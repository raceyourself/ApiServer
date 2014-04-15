class CreateGroupsUsersTable < ActiveRecord::Migration
  def up
    create_table :groups_users, :id => false do |t|
      t.references :user, :null => false
      t.references :group, :null => false
    end
    add_index :groups_users, [:user_id, :group_id]
    add_index :groups_users, :group_id
  end
  def down
    drop_table :groups_users
  end
end
