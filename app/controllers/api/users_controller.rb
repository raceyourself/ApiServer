module Api
  class UsersController < BaseController
    
    def index
      expose user.peers
    end

    def show
      expose User.find(params[:id])
    end

  end
end
