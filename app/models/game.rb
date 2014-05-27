class Game < ActiveRecord::Base
  self.inheritance_column = 'class' # STI not used

  acts_as_paranoid
  has_many :menu_items
  has_many :game_states, :dependent => :destroy
end
