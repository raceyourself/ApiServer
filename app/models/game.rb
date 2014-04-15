class Game < ActiveRecord::Base
  self.inheritance_column = 'class' # STI not used

  has_many :menu_items
  has_many :game_states
end
