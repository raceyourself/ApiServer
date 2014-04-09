module Concerns
  module UserAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = []
    TABLES = [:devices, :positions, :tracks, :notifications, :events]

    included do
      has_many :devices
      has_many :tracks
      has_many :notifications
      has_many :events
      has_many :challenge_subscribers
      has_many :challenges, :through => :challenge_subscribers

      define_method :positions do |scope=:all|
        Position.send(scope).where(user_id: id).where('state_id >= 0')
      end

      # has many associations
      COLLECTIONS.each do |assoc|
        # association getter
        define_method assoc do |scope=:all|
          klass = "#{assoc.to_s}".classify.constantize
          klass.send(scope).where(user_id: id)
        end unless method_defined? assoc
      end

    end #included

  end
end 
