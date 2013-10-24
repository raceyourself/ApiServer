module Api
  class CredentialsController < BaseController
    doorkeeper_for :all
    
    caches :show, caches_for: 5.minutes

    def show
      expose user, include: { authentications: { only: [ :provider, :uid, :permissions ] } }
    end
    
  end
end
