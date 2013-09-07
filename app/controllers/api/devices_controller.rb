module Api
  class DevicesController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.devices
    end

    def show
      expose current_resource_owner.devices.find(params[:id])
    end

  end
end