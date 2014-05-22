module Surveys
  class BetaInsightController < ActionController::Base

    def index
      # get survey reponses from query string and save them to database
      path_params = request.path_parameters
      survey_responses = (params.except(*path_params.keys).except('id').permit!).inspect
      puts survey_responses #log so we can see them
      
      if (survey_responses["email"].defined?) then
        i = new SurveyBetaInsight survey_reponses
        puts i.inspect
      end
      

      redirect_to "/"
    end

  end
end
