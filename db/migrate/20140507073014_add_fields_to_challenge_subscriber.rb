class AddFieldsToChallengeSubscriber < ActiveRecord::Migration
  def up
    add_column :challenge_subscribers, :accepted, :boolean, default: false
  end
  def down
    remove_column :challenge_subscribers, :accepted
  end
end
