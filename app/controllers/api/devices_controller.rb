module Api
  class DevicesController < BaseController
    doorkeeper_for :all

    def index
      expose user.devices
    end

    def show
      expose user.devices.find(params[:id])
    end

  end
end