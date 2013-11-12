module Concerns
  module DocumentAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = [:devices, :friends, :challenges, :orientations, :positions, :tracks, :transactions, :notifications]

    included do
      define_method :friends do |scope=:all|
        identities = Identity.send(scope).where(user_id: id)
        Friendship.send(scope).where(:identity_id.in => identities.flat_map { |id| id.id })
      end

      define_method :challenges do |scope=:all|
        Challenge.send(scope).where(creator_id: id)
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
