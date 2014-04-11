module Api
  class ConfigurationsController < BaseController
    doorkeeper_for :all

    def show
      expose ::Configuration.for(user, params[:id])
    end

  end
end
