class AddAdditionalGameStates < ActiveRecord::Migration
  def up
    GameState.create!(:enabled => false, :group_id => Group.find_by!(:name => "Beta"), :game_id => 'activity_bike')
    GameState.create!(:enabled => true, :group_id => Group.find_by!(:name => "Zombie"), :game_id => 'activity_food_burn')
  end
  def down
    # TODO. note that the previous migration rollback will remove this, so you can just
    # rollback twice and migrate forwards one step...
  end
end
