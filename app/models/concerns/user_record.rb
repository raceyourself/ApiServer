module Concerns
  module UserRecord
    extend ActiveSupport::Concern

    included do
      belongs_to :user
      acts_as_paranoid
    end
    
    def merge
      self.save!
    end

    def serializable_hash(options = {})
      # Return plain attributes if no options or default rocket_pants options
      if options.nil? || options.except(:url_options, :root, :compact).empty?
        attributes
      else
        super(options)
      end
    end

  end
end
