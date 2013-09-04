module Api
  class BaseController < RocketPants::Base
    include ActionController::Head
    include Doorkeeper::Helpers::Filter
  
    version 1

    map_error! ActiveRecord::RecordNotFound, RocketPants::NotFound

    # For the api to always revalidate on expiry.
    caching_options[:must_revalidate] = true

  end
end