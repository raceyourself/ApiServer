class AddAuthenticationsPermissions < ActiveRecord::Migration
  def change
    add_column :authentications, :permissions, :string
  end
end
