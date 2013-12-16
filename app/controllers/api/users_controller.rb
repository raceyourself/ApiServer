module Api
  class UsersController < RocketPants::Base
    include ActionController::Head
    include Doorkeeper::Helpers::Filter
  
    version 1

    map_error! ActiveRecord::RecordNotFound, RocketPants::NotFound
    map_error! Mongoid::Errors::DocumentNotFound, RocketPants::NotFound

    # For the api to always revalidate on expiry.
    caching_options[:must_revalidate] = true

    def index
      expose User.all, methods: :points
    end

    def show
      expose User.find(params[:id])
    end

  end
end
