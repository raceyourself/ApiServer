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
      v = AnalyticsView.new(_id: params[:id], script: request.raw_post)
      v.upsert if v.valid?
      render :json => v
    end

  end
end
