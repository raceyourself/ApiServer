module Api
  class ChallengesController < BaseController
    doorkeeper_for :all

    def index
      # TODO: Don't show timed out? Only list public here?
      expose Challenge.all
    end

    def show
      # TODO: ACL, serialization_hash in subtype
      composite = params[:id].match(/(-?\d+)-(\d+)/)[1..2]
      if stale?(:last_modified => Challenge.where(device_id: composite[0], challenge_id: composite[1]).pluck(:updated_at).first)
        expose Challenge.find(composite)
      end
    end

  end
end
