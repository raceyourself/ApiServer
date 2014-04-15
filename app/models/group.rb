class Group < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :users
  has_many :game_states

  # validations
  validates :name, presence: true
end
