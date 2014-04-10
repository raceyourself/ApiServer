module Concerns
  module UserAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = [:devices, :positions, :tracks, :notifications, :challenges, :events]

    included do
      has_many :devices
      has_many :tracks
      has_many :transactions
      has_many :notifications
      has_many :events
      has_many :challenge_subscribers
      has_many :challenges, :through => :challenge_subscribers

      define_method :friends do |scope=:all|
        Friendship.send(scope).joins(:identity).where(:identities => {:user_id => id})
      end

      define_method :positions do |scope=:all|
        Position.send(scope).where(user_id: id).where('state_id >= 0')
      end

    end #included

  end
end 
