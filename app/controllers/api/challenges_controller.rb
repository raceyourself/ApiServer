module Api
  class ChallengesController < BaseController
    doorkeeper_for :all

    def index
      # TODO: Don't show timed out? Only list public here?
      expose Challenge.all, methods: :type
    end

    def show
      # TODO: ACL, serialization_hash in subtype
      expose Challenge.find(params[:id]), { methods: :type, 
                                            except: :attempt_ids, 
                                            include: { 
                                              attempts: { only: [ :device_id, :track_id, :user_id ] } 
                                            } 
                                          }
    end

  end
end
