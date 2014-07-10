module Api
  class ChallengesController < BaseController
    doorkeeper_for :all

    def index
      # TODO: Don't show timed out? Only list public here?
      expose Challenge.all
    end

    def show
      # TODO: ACL, serialization_hash in subtype
      expose Challenge.find(params[:id].match(/(-?\d+)-(\d+)/)[1..2])
    end

  end
end
