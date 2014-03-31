module Analytics
  class EventsController < AuthedController
    before_filter do
       head :forbidden and return unless current_user && current_user.admin?
    end

    def show
      query = AnalyticsQuery.find(params[:id])
      results = Event.collection.aggregate(query.query) if query
      render :json => results
    end

  end
end
