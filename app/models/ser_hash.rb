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

    Hash[subset.map { |k, v| [k.to_s, serialize_value(v, options)] }]
  end

  def serialize_value(v, options)
    if v.respond_to?(:serializable_hash)
      v.serializable_hash(options)
    elsif v.is_a?(Array)
      v.map { |e| serialize_value(e, options) }
    elsif v.respond_to?(:entries)
      serialize_value(v.entries, options)
    else
      v
    end
  end

end
