class MakeTimestampsLongs < ActiveRecord::Migration
  def up
    change_column :positions,    :device_ts, :integer, :null => false, :limit => 8
    change_column :positions,    :gps_ts,    :integer, :null => false, :limit => 8
    change_column :tracks,       :ts,        :integer, :null => false, :limit => 8
    change_column :transactions, :ts,        :integer, :null => false, :limit => 8
  end
  def down
  end
end
