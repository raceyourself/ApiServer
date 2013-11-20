module Api
  class TracksController < BaseController
    doorkeeper_for :all

    def index
      expose user.tracks
    end

    def show
      expose Track.find(params[:id]), methods: :positions
    end

  end
end
