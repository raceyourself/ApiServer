module Api
  class OrientationsController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.orientations
    end

    def show
      expose current_resource_owner.orientations.find(params[:id])
    end

  end
end