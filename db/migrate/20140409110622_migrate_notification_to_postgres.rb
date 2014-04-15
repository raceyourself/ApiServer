class MigrateNotificationToPostgres < ActiveRecord::Migration
  def up
    create_table :notifications do |t|
      t.boolean  :read,           :null => false, :default => false
      t.column   :message, :json, :null => false
      # user record fields:
      t.integer  :user_id,        :null => false
      t.timestamps
      t.datetime :deleted_at
      t.index    :user_id
    end
  end
  def down
    drop_table 'notifications'
  end
end
