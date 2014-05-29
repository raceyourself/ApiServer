class CreateInvites < ActiveRecord::Migration
  def up
    create_table :invites, :id => false do |t|
      t.string :code, :null => false
      t.datetime :expires_at
      t.datetime :used_at

      # has_one referrer
      t.integer :user_id
      # has_one invited identity
      t.string :identity_type
      t.string :identity_uid
    end
    execute 'ALTER TABLE invites ADD PRIMARY KEY (code);'
    add_index :invites, [:identity_type, :identity_uid]
    add_column :users, :invites, :integer, :default => 0
  end
  def down
    drop_table 'invites'
    remove_column :users, :invites
  end
end
