Analytics = AnalyticsRuby       # Alias for convenience
Analytics.init({
    secret: CONFIG[:segment_io][:write_key],          # The write key for raceyourself/api
    on_error: Proc.new { |status, msg| print 'Analytics error: ' + msg }  # Optional error handler
})
