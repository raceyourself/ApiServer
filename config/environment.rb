# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'analytics-ruby'

# Initialize the Rails application.
GfAuthenticate::Application.initialize!

# Initialize segment.io analytics (see https://segment.io/docs/libraries/ruby/)
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked # We're in smart spawning mode.
      require File.expand_path('../initializers/analytics_ruby', __FILE__)
      require File.expand_path('../initializers/sidekiq_client', __FILE__)
    else
      # We're in direct spawning mode. We don't need to do anything.
    end
  end
end

# BetWorker should be called by cron, no need to initialize on environment load
# Calling it here can cause rake db:migrate to fall over as it expects tables to be present
#BotWorker.initialize

