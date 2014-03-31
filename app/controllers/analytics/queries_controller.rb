module Analytics
  class QueriesController < AuthedController
    before_filter do
       head :forbidden and return unless current_user && current_user.admin?
    end

    def index
      render :json => AnalyticsQuery.all
    end

    def show
      render :json => AnalyticsQuery.find(params[:id])
    end

    def update
      q = AnalyticsQuery.new(_id: params[:id], query: params[:query])
      q.upsert if q.valid?
      render :json => q
    end

  end
end
