module Analytics
  class EventsController < AuthedController
    before_filter do
       head :forbidden and return unless current_user && current_user.admin?
    end

    def show
      aq = AnalyticsQuery.find(params[:id])
      query = aq.query if aq
      query = query[:_json] if query && query[:_json] 
      results = Event.collection.aggregate(query) if query
      render :json => results
    end

  end
end
