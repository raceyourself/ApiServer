source 'https://rubygems.org'

# core
gem 'rails', '4.0.0'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
#gem 'turbolinks'
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# util
gem 'bson_ext'

# data
gem 'composite_primary_keys'
gem "paranoia", "~> 2.0"
gem 'pg'

# pagination
gem 'kaminari'

# layout
gem 'therubyracer'
gem 'less-rails'
gem 'twitter-bootstrap-rails'
gem 'haml'

# authentication
gem 'devise'
gem 'devise-async'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
# gem 'omniauth-google-oauth2'
# gem 'omniauth-gplus'
# gem 'omniauth-linkedin'
# gem 'omniauth-google'
gem 'doorkeeper', '~> 0.7.0'

# forms
gem 'simple_form', '~> 3.0.0.beta1'
gem 'carrierwave'
gem 'mini_magick'

#caching
gem 'dalli'
gem 'rack-cache'

#api
gem 'rocket_pants'

#json
gem 'oj'
gem 'yajl-ruby', :require => 'yajl'

# admin
gem 'rails_admin'

# worker
gem 'sinatra'
gem 'sidekiq'
gem 'whenever', :require => false

# social
gem 'koala'
gem 'twitter'
gem 'google-api-client'

# analytics
gem 'newrelic_rpm'
gem 'rocket_pants-rpm'
#gem 'newrelic_moped'
gem 'staccato'
gem 'analytics-ruby', '~>1.0'

# push notifications
gem 'gcm'
gem 'apns'

# e-mail
gem 'mandrill-api'

# profiling
gem 'ruby-prof'

group :development, :test do
  gem 'faker'
  gem 'pry'
  gem 'pry-remote'
  gem 'debugger-pry'
  gem 'factory_girl_rails'
  gem 'letter_opener'
  gem 'shoulda-matchers'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'html2haml'
  # deployer
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-sidekiq'
end

group :test do
  gem 'turnip'
  gem 'rspec-rails'
  #gem 'mongoid-rspec', '~> 1.4.5'
  gem 'capybara'
  gem 'capybara-webkit', '0.12.1'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'fakeweb'
  gem 'webmock'
  gem 'email_spec'
  gem 'headless'
  gem 'timecop'
end
