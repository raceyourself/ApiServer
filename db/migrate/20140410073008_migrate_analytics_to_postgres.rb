class MigrateAnalyticsToPostgres < ActiveRecord::Migration
  def up
    create_table :analyticsqueries, :id => false do |t|
      t.string :id,  :null => false
      t.string :sql, :null => false
      t.timestamps
    end
    execute 'ALTER TABLE analyticsqueries ADD PRIMARY KEY (id);'
    create_table :analyticsviews, :id => false do |t|
      t.string :id,     :null => false
      t.string :script, :null => false
      t.timestamps
    end
    execute 'ALTER TABLE analyticsviews ADD PRIMARY KEY (id);'
  end
  def down
    drop_table 'analyticsqueries'
    drop_table 'analyticsviews'
  end
end
