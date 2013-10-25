module Api
  class FriendsController < BaseController
    doorkeeper_for :all

    def index
      expose user.friends, { include: :friend, except: [:friend_id, :friend_type] }
    end

    def show
      expose Friendship.find(params[:id]), { include: :friend, except: [:friend_id, :friend_type] }
    end

  end
end
