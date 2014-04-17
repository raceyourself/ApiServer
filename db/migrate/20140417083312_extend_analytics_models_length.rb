class ExtendAnalyticsModelsLength < ActiveRecord::Migration
  def up
    change_column :analytics_queries, :sql, :text,    :null => false 
    change_column :analytics_views,   :script, :text, :null => false 
  end
  def down
  end
end
