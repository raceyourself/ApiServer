config = YAML.load_file("#{Rails.root}/config/config.yml") || {}
config.merge!(config[Rails.env]) if config[Rails.env]
CONFIG = config.with_indifferent_access