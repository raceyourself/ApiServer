class RenameUserInvitesColumn < ActiveRecord::Migration
  def up
    rename_column :users, :invites, :generated_invites
  end
  def down
    rename_column :users, :generated_invites, :invites
  end
end
