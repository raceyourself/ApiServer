module Api
  class DevicesController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.devices
    end

  end
end