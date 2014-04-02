module Analytics
  class EventsController < AuthedController
    before_filter do
       head :forbidden and return unless current_user && current_user.admin?
    end

    def show
      aq = AnalyticsQuery.find(params[:id])
      begin
        results = ActiveRecord::Base.connection.execute(aq.sql) if aq && aq.sql
      rescue Exception=>e
        results = e
      end
      render :json => results
    end

  end
end
