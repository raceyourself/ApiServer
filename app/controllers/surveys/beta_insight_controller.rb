module Surveys
  class BetaInsightController < ActionController::Base

    def index
      # get survey reponses from query string and save them to database
      puts "New survey response hit api with params: " + params.inspect

      # collect the parameters we require/permit
      params.require(:email)
      permitted = params.permit(:email, :first_name, :last_name, :phone_number, :url, :gender, :age_group, :country, :mobile_device_1, :mobile_device_2, :wearable_devices, :running_fitness, :cycling_fitness, :workout_fitness, :goals)
 
      # save to db
      i = SurveyBetaInsight.new(permitted)
      i.save!

      redirect_to "http://www.raceyourself.com"
    end

  end
end
