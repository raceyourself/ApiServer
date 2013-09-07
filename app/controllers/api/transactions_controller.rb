module Api
  class TransactionsController < BaseController
    doorkeeper_for :all

    def index
      expose current_resource_owner.transactions
    end

    def show
      expose current_resource_owner.transactions.find(params[:id])
    end

  end
end