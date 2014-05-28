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
                                :country_as_entered,
                                :mobile_device_1, 
                                :mobile_device_2, 
                                :running_fitness, 
                                :cycling_fitness, 
                                :workout_fitness)
 
      merged = {}
      # nested strong parameters with integer keys are broken for some reason
      merged[:wearable_devices] = params.fetch(:wearable_devices) if params.has_key?(:wearable_devices)
      merged[:goals] = params.fetch(:goals) if params.has_key?(:goals)
      # request fields 
      # TODO: allow these to be overriden if we upgrade to webhooks
      merged[:time_submitted] = Time.now # TODO: format?
      merged[:language] = request.env['HTTP_ACCEPT_LANGUAGE']
      merged[:ip_address] = request.remote_ip
      merged[:user_agent] = request.user_agent
      # save to db
      i = SurveyBetaInsight.new(permitted.merge(merged))
      i.save!

      redirect_to "http://www.raceyourself.com/signed_up"
    end

  end
end
