module Api
  class FriendsController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.friends
    end

    def show
      expose current_resource_owner.friends.find(params[:id])
    end

  end
end