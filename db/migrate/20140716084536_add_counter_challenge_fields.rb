class AddCounterChallengeFields < ActiveRecord::Migration
  def up
    add_column :challenges, :counter, :string
    add_column :challenges, :value, :integer
  end
  def down
    remove_column :challenges, :counter
    remove_column :challenges, :value
  end
end
