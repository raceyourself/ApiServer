class CreateAuthentications < ActiveRecord::Migration
  def up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.text :provider_data
      t.string :email
      t.string :token
      t.string :token_secret
      t.boolean :token_expires
      t.datetime :token_expires_at
      t.string :refresh_token

      t.timestamps
    end

    User.all.each do |u|
      u.authentications.create(provider: u.provider, uid: u.uid) if u.uid
    end

    remove_column :users, :provider
    remove_column :users, :uid
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    User.all.each do |u|
      if auth = u.authentication.first
        u.provider = auth.provider
        u.uid = auth.uid
        u.save
      end
    end

    drop_table :authentications
  end
end
