class AddChallengeCompoundPk < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE challenges DROP CONSTRAINT challenges_pkey;'
    add_column :challenges, :device_id, :integer, :default => -1, :null => false
    rename_column :challenges, :id, :challenge_id
    execute 'ALTER TABLE challenges ADD PRIMARY KEY (device_id,challenge_id);'
    execute 'ALTER TABLE challenge_attempts DROP CONSTRAINT challenge_attempts_pkey'
    add_column :challenge_attempts, :challenge_device_id, :integer, :default => -1, :null => false
    rename_column :challenge_attempts, :device_id, :track_device_id
    execute 'ALTER TABLE challenge_attempts ADD PRIMARY KEY (challenge_device_id,challenge_id,track_device_id,track_id);'
    execute 'ALTER TABLE challenge_subscribers DROP CONSTRAINT challenge_subscribers_pkey;'
    add_column :challenge_subscribers, :device_id, :integer, :default => -1, :null => false
    execute 'ALTER TABLE challenge_subscribers ADD PRIMARY KEY (device_id,challenge_id,user_id);'
  end
  def down
    execute 'ALTER TABLE challenges DROP CONSTRAINT challenges_pkey;'
    remove_column :challenges, :device_id
    rename_column :challenges, :challenge_id, :id
    execute 'ALTER TABLE challenges ADD PRIMARY KEY (id);'
    execute 'ALTER TABLE challenge_attempts DROP CONSTRAINT challenge_attempts_pkey'
    remove_column :challenge_attempts, :challenge_device_id
    rename_column :challenge_attempts, :track_device_id, :device_id
    execute 'ALTER TABLE challenge_attempts ADD PRIMARY KEY (challenge_id,device_id,track_id);'
    execute 'ALTER TABLE challenge_subscribers DROP CONSTRAINT challenge_subscribers_pkey;'
    remove_column :challenge_subscribers, :device_id
    execute 'ALTER TABLE challenge_subscribers ADD PRIMARY KEY (challenge_id,user_id);'
  end
end
