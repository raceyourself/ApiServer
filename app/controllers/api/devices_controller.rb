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
      expose Device.create!(params.except(*path_params.keys).except('id').permit!)
    end

  end
end
