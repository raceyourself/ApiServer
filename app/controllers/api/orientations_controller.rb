module Api
  class OrientationsController < BaseController
    doorkeeper_for :all

    def index
      expose user.orientations
    end

    def show
      expose user.orientations.find(params[:id])
    end

  end
end