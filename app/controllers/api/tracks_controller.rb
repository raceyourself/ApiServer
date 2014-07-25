module Api
  class TracksController < BaseController
    doorkeeper_for :all

    def index
      expose user.tracks
    end

    def show
      composite = params[:id].split('-', 2)
      track_updated_at = Track.where(device_id: composite[0], track_id: composite[1]).pluck(:updated_at).first
      tp_updated_at = Position.where(device_id: composite[0], track_id: composite[1]).maximum(:updated_at)
      updated_at = [track_updated_at, tp_updated_at].compact.max
      if stale?(:last_modified => updated_at)
        track = Track.find(composite)
        # Long cache time for completed tracks
        response.cache_control[:max_age] = 60*60 if track && track.time
        expose track, methods: :positions
      end
    end

  end
end
