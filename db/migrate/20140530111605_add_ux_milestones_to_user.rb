class AddUxMilestonesToUser < ActiveRecord::Migration
  def change
    add_column :users, :ux_milestones, :json, :default => {}
  end
end
