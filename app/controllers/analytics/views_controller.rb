module Analytics
  class ViewsController < AuthedController
    before_filter do
       head :forbidden and return unless current_user && current_user.admin?
    end

    def index
      render :json => AnalyticsView.all
    end

    def show
      render :json => AnalyticsView.find(params[:id])
    end

    def update
      v = AnalyticsView.find_or_initialize_by_id(params[:id])
      v.script = request.raw_post
      v.save!
      render :json => v
    end

  end
end
