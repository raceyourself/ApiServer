module Concerns
  module UserRecord
    extend ActiveSupport::Concern

    included do
      belongs_to :user
      acts_as_paranoid
    end
    
    def merge
      hash = self.serializable_hash.except('created_at', 'deleted_at', 'updated_at')
      key = hash.extract!(*self.class.primary_key)
      begin
        o = self.class.find(key.values)
        # Update
        o.updated_at = Time.now
        o.update!(hash)
      rescue ActiveRecord::RecordNotFound => e
        # Insert
        self.save!
      end
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
