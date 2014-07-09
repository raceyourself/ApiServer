class AddTimestampsToInvite < ActiveRecord::Migration
  def up
    add_timestamps(:invites)
    add_column :invites, :deleted_at, :datetime
  end
  def down
    remove_timestamps(:invites)
    add_column :invites, :deleted_at
  end
end
