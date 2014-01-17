module Api
  class PositionsController < BaseController
    doorkeeper_for :all

    def index
      expose user.positions.gte(state_id: 0)
    end

    def show
      expose user.positions.find(params[:id])
    end

  end
end
