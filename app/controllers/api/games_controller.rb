module Api
  class GamesController < BaseController
    doorkeeper_for :all

    def index
      if stale?(:last_modified => GameState.last_modified)
        expose user.games
      end
    end

  end
end
