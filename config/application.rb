require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module GfAuthenticate
  class Application < Rails::Application

    # This can probably come out
    mem_config = YAML.load_file("#{Rails.root}/config/memcached.yml") || {}
    mem_config = mem_config[Rails.env]
    mem_servers = mem_config['host'].split(' ').map{|h| "#{h}:#{mem_config['port']}"}

    config.cache_store = :dalli_store, mem_servers, { expires_in: 1.day, compress: true }

    config.action_dispatch.rack_cache = {
      metastore:   Dalli::Client.new,
      entitystore: Dalli::Client.new,
      verbose: false
    }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_mailer.default_url_options = { host: 'glassfit.dannyhawkins.co.uk' }


    config.generators do |g|
      g.orm                 :active_record
      g.stylesheets         false
      g.test_framework      :rspec
      g.template_engine     :haml
    end

    config.after_initialize do
      OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    end

  end


  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {  
    address:              'localhost', 
    port:                 25,  
    domain:               'dannyhawkins.co.uk',  
    enable_starttls_auto: true,
    openssl_verify_mode:  'none'
  }

end
