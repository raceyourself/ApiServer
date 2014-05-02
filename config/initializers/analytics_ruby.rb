Analytics = AnalyticsRuby       # Alias for convenience
Analytics.init({
    secret: 'uw6ekt93ry',          # The write key for raceyourself/api
    on_error: Proc.new { |status, msg| print msg }  # Optional error handler
})
