module Concerns
  module DocumentAssociations
    extend ActiveSupport::Concern

    COLLECTIONS = [:devices, :friends, :orientations, :positions, :tracks, :transactions]

    included do
      # has many associations
      COLLECTIONS.each do |assoc|
        # association getter
        define_method assoc do
          klass = "#{assoc.to_s}".classify.constantize
          klass.where(user_id: id)
        end
      end

    end #included

  end
end 