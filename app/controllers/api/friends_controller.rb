module Api
  class FriendsController < BaseController
    doorkeeper_for :all

    def index
      # TODO: Include friend identity, filter out foreign keys
      expose user.friends
    end

    def show
      # TODO: Look up identity, filter away if not in friendship
      expose Friendship.find(params[:id])
    end

  end
end
