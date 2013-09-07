module Api
  class TracksController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.tracks
    end

    def show
      expose current_resource_owner.tracks.find(params[:id])
    end

  end
end