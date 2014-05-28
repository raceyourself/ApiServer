module Surveys
  class BetaInsightController < ActionController::Base

    def index
      # get survey reponses from query string and save them to database
      # collect the parameters we require/permit
      params.require(:email)
      permitted = params.permit(:email, 
                                :first_name, 
                                :last_name, 
                                :phone_number, 
                                :url, 
                                :gender, 
                                :age_group, 
                                :country, 
                                :mobile_device_1, 
                                :mobile_device_2, 
                                :running_fitness, 
                                :cycling_fitness, 
                                :workout_fitness)
 
      # nested strong parameters with integer keys are broken for some reason
      nested = {}
      nested[:wearable_devices] = params.fetch(:wearable_devices) if params.has_key?(:wearable_devices)
      nested[:goals] = params.fetch(:goals) if params.has_key?(:goals)
      # save to db
      i = SurveyBetaInsight.new(permitted.merge(nested))
      i.save!

      redirect_to "http://www.raceyourself.com/signed_up"
    end

  end
end
