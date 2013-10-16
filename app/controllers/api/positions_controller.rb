module Api
  class PositionsController < BaseController
    doorkeeper_for :all

    def index
      expose user.positions
    end

    def show
      expose user.positions.find(params[:id])
    end

  end
end