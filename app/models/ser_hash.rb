class SerHash < Hash
  
  def serializable_hash(options = {})
    # create a subset of the hash by applying :only or :except
    subset = if options
      if attrs = options[:only]
        slice(*Array(attrs))
      elsif attrs = options[:except]
        except(*Array(attrs))
      else
        self
      end
    else
      self
    end

    Hash[subset.map { |k, v| [k.to_s, v.respond_to?(:serializable_hash) ? v.serializable_hash(options) : v] }]
  end

end
