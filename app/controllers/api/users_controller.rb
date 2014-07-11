module Api
  class UsersController < BaseController
    doorkeeper_for :all
    
    def index
      expose user.peers
    end

    def show
      if stale?(:last_modified => User.where(id: params[:id]).pluck(:updated_at).first)
        expose User.find(params[:id])
      end
    end

  end
end
