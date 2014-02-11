module Api
  class TracksController < BaseController
    doorkeeper_for :all

    def index
      expose user.tracks
    end

    def show
      id = params[:id]
      composite = id.split('-')
      if composite.length == 2
        track = Track.where({device_id: composite[0], track_id: composite[1]}).first
      else
        track = Track.find(id)
      end
      # Long cache time for completed tracks
      response.cache_control[:max_age] = 60*60 if track && track.time
      expose track, methods: :positions
    end

  end
end
