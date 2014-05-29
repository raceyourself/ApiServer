class AddCohortToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cohort, :string
  end
end
