class RenameAnalyticsTables < ActiveRecord::Migration
  def up
    rename_table 'analyticsqueries', 'analytics_queries'
    rename_table 'analyticsviews', 'analytics_views'
  end
  def down
    rename_table 'analytics_queries', 'analyticsqueries'
    rename_table 'analytics_views', 'analyticsviews'
  end
end
