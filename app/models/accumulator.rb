class Accumulator < ActiveRecord::Base
  self.primary_keys = :name, :user_id
  belongs_to :user

  def self.add(name, user_id, value)
    Accumulator.find_or_create_by(name: name, user_id: user_id)
    Accumulator.update_counters([name, user_id], value: value)
  end
end
