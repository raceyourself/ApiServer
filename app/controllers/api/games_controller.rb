module Api
  class GamesController < BaseController
    doorkeeper_for :all

    def index
      expose user.games
    end

  end
end
