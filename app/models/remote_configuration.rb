class RemoteConfiguration
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  # fields
  field :type,          type: String
  field :configuration, type: Hash # Actual configuration
  field :group,         type: Integer, default: nil # nil == default
end
