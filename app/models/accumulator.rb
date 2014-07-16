class Accumulator < ActiveRecord::Base
  self.primary_keys = :name, :user_id
  belongs_to :user
end
