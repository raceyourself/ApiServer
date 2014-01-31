class Group < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :users

  # validations
  validates :name, presence: true
end
