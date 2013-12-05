module Api
  class CredentialsController < BaseController
    doorkeeper_for :all
    
    def show
      expose user, include: { authentications: { only: [ :provider, :uid, :permissions ] } }
    end
    
  end
end
