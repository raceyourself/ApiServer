# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'analytics-ruby'

# Initialize the Rails application.
GfAuthenticate::Application.initialize!

# Initialize segment.io analytics (see https://segment.io/docs/libraries/ruby/)
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked # We're in smart spawning mode.
      Analytics = AnalyticsRuby     # Alias for convenience
      Analytics.init({
        secret: 'YOUR_WRITE_KEY',        # The write key for #{project.owner.login}/#{project.slug}
        on_error: Proc.new { |status, msg| print msg }  # Optional error handler
      })
    else
      # We're in direct spawning mode. We don't need to do anything.
    end
  end
end
