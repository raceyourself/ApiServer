module Concerns
  module DocumentAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = [:devices, :friends, :orientations, :positions, :tracks, :transactions, :notifications]

    included do
      define_method :friends do
        identities = Identity.where(user_id: id)
        # TODO: Include friend identities, filter out foreign keys
        Friendship.where(:identity_id.in => identities.flat_map { |id| id.id })
      end

      # has many associations
      COLLECTIONS.each do |assoc|
        # association getter
        define_method assoc do
          klass = "#{assoc.to_s}".classify.constantize
          klass.where(user_id: id)
        end unless method_defined? assoc
      end

    end #included

  end
end 
