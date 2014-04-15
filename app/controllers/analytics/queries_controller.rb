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
      q = AnalyticsQuery.find_or_initialize_by_id(params[:id])
      q.sql = request.raw_post
      q.save!
      render :json => q
    end

  end
end
