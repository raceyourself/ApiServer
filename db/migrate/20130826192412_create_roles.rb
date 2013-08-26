class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    create_table :roles_users, id: false do |t|
      t.integer :user_id, null: false
      t.integer :role_id, null: false
    end

    add_index :roles_users, [:user_id, :role_id]
  end

end
