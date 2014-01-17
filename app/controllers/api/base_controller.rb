module Api
  class BaseController < RocketPants::Base
    include ActionController::Head
    include Doorkeeper::Helpers::Filter
  
    version 1

    map_error! ActiveRecord::RecordNotFound, RocketPants::NotFound
    map_error! Mongoid::Errors::DocumentNotFound, RocketPants::NotFound
    map_error! Mongoid::Errors::UnknownAttribute, RocketPants::BadRequest

    # For the api to always revalidate on expiry.
    caching_options[:must_revalidate] = true

    def user
      if params[:user_id]
        # TODO: Check visibility/role
        User.find(params[:user_id]) 
      else
        current_resource_owner
      end
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def encode_to_json(object)
      MultiJson.encode object
    end

  end
end
