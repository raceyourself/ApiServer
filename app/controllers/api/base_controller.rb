module Api
  class BaseController < RocketPants::Base
    include ActionController::Head
    include Doorkeeper::Helpers::Filter
  
    version 1

    map_error! ActiveRecord::RecordNotFound, RocketPants::NotFound

    around_filter :profile if Rails.env != 'production'

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

    def profile
      if params[:profile_ruby] && result = RubyProf.profile { yield }
        out = StringIO.new
        RubyProf::GraphHtmlPrinter.new(result).print out, :min_percent => 0
        body = out.string
        self.response_body = body
        self.response.headers['Content-Type'] = 'text/html'
        self.response.headers['Content-Length'] = body.length.to_s
      else
        yield
      end
    end

  end
end
