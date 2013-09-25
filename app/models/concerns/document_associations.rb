module Concerns
  module DocumentAssociations
    extend ActiveSupport::Concern

    included do
      # has many associations
      [:devices, :friends, :orientations, :positions, :tracks, :transactions].each do |assoc|
        # association getter
        define_method assoc do
          klass = "#{assoc.to_s}".classify.constantize
          klass.where(user_id: id)
        end
      end

    end #included

  end
end 