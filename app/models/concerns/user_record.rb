module Concerns
  module UserRecord
    extend ActiveSupport::Concern

    included do
      belongs_to :user
      acts_as_paranoid
    end
    
    def merge
      # TODO: Improve performance:
      #       Do  a) update! || save for things likely to always exist
      #       and b) create! || update for things likely to not exist
      #       Surround data_controller::import with a transaction
      # NOTE: update_all should bypass object instantiation
      #       activerecord-import could work similarly for inserts
      #       data validation is the only problem
      hash = self.serializable_hash.except('created_at', 'deleted_at', 'updated_at', 'guid')
      key = hash.extract!(*self.class.primary_key)
      id = key.values
      id = key.values[0] if key.length == 1
      this = self
      begin
        o = self.class.with_deleted.find(id)
        self.class.before_merge(o, self) if self.class.respond_to? :before_merge
        # Update
        hash['updated_at'] = Time.now
        hash['deleted_at'] = nil
        o.update!(hash)
        this = o
      rescue ActiveRecord::RecordNotFound => e
        # Insert
        self.save!
      end
      this
    end

    def merge_delete(user)
      # Do not allow merge deletes by default
    end

    def serializable_hash(options = {})
      hash = nil
      # Return plain attributes if no options or default rocket_pants options
      if options.nil? || options.except(:url_options, :root, :compact).empty?
        hash = attributes
      else
        hash = super(options)
      end
      # guids for ORMs that don't support compound PKs
      hash['guid'] = self.guid if self.respond_to? :guid
      hash
    end

    def cache_key
      if deleted_at = self[:deleted_at]
        "#{super}-#{deleted_at.utc.to_s(:number)}"
      else
        super
      end
    end

    def as_json(options={})
      exopts = options.except(:url_options, :_recall, :script_name)
      unless exopts.except(:include, :version, :root).empty?
        return super(options)
      end
      Rails.cache.fetch("#{cache_key}/as_json/#{Digest::MD5.hexdigest(options.to_s)}") do
        super(options)
      end
    end

  end
end
