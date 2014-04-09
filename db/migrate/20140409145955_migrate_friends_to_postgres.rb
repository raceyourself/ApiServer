class MigrateFriendsToPostgres < ActiveRecord::Migration
  def up
    create_table :identities, :id => false do |t|
      t.integer  :user_id # May be null
      t.boolean  :has_glass,  :default => false

      t.string   :type  # Single table inheritance

      t.string   :uid,        :null => false
      t.string   :name
      t.string   :photo
      t.string   :screen_name   # TwitterIdentity

      t.index    :user_id
    end
    execute 'ALTER TABLE identities ADD PRIMARY KEY (type,uid);'
    create_table :friendships, :id => false do |t|
      t.string :identity_type
      t.string :identity_uid
      t.string :friend_type
      t.string :friend_uid

      t.timestamps
      t.datetime :deleted_at
    end
    execute 'ALTER TABLE friendships ADD PRIMARY KEY (identity_type,identity_uid,friend_type,friend_uid);'
  end
  def down
    drop_table 'identities'
    drop_table 'friendships'
  end
end
