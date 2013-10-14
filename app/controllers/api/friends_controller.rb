module Api
  class FriendsController < BaseController
    doorkeeper_for :all

    def index
      expose user.friends
    end

    def show
      expose user.friends.find(params[:id])
    end

  end
end