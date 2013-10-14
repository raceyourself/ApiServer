module Api
  class TracksController < BaseController
    doorkeeper_for :all

    def index
      expose user.tracks
    end

    def show
      expose user.tracks.find(params[:id])
    end

  end
end