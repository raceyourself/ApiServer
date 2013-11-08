module Api
  class ChallengesController < BaseController
    doorkeeper_for :all

    def index
      expose Challenge.all, methods: :type
    end

    def show
      expose Challenge.find(params[:id]), methods: :type
    end

  end
end
