module Api
  class ConfigurationsController < BaseController
    doorkeeper_for :all

    def show
      groups = user.group_ids
      configuration = RemoteConfiguration.where(type: params[:id]).where(:group.in => groups).first
      configuration = RemoteConfiguration.where(type: params[:id]).where(group: nil).first unless configuration
      expose configuration
    end

  end
end
