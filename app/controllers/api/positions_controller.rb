module Api
  class PositionsController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.positions
    end

    def show
      expose current_resource_owner.positions.find(params[:id])
    end

  end
end