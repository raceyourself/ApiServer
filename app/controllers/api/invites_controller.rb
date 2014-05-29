module Api
  class InvitesController < BaseController
    doorkeeper_for :all

    def index
      expose Invite.generate_for(user)
    end

  end
end
