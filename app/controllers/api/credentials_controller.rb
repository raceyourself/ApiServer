module Api
  class CredentialsController < BaseController
    doorkeeper_for :all
    
    caches :show, caches_for: 5.minutes

    def show
      expose user
    end
    
  end
end