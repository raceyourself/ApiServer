class MigrateChallengesToPostgres < ActiveRecord::Migration
  def up
    create_table :challenges do |t|
      t.datetime :start_time
      t.datetime :stop_time
      t.boolean  :public,    :default => false

      t.integer  :creator_id # User foreign key, nullable

      t.string   :type # Single inheritance table

      t.integer  :distance  # DistanceChallenger, DurationChallenge, PaceChallenge
      t.integer  :time      # DistanceChallenge
      t.integer  :duration  # DurationChallenge
      t.integer  :pace      # PaceChallenge

      t.timestamps
      t.datetime :deleted_at
    end
    create_table :challenge_attempts, :id => false do |t|
      t.integer :challenge_id
      t.integer :device_id
      t.integer :track_id
    end
    execute 'ALTER TABLE challenge_attempts ADD PRIMARY KEY (challenge_id,device_id,track_id);'
    create_table :challenge_subscribers, :id => false do |t|
      t.integer :challenge_id
      t.integer :user_id
    end
    execute 'ALTER TABLE challenge_subscribers ADD PRIMARY KEY (challenge_id,user_id);'
  end
  def down
    drop_table 'challenges'
    drop_table 'challenge_attempts'
    drop_table 'challenge_subscribers'
  end
end
