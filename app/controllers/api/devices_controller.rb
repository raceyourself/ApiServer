module Api
  class DevicesController < BaseController
    doorkeeper_for :index, :show

    def index
      expose user.devices
    end

    def show
      expose user.devices.find(params[:id])
    end

    def create
      path_params = request.path_parameters
      logger.info params.except(*path_params.keys)
      expose Device.create!(params.except(*path_params.keys).permit!)
    end

  end
end
