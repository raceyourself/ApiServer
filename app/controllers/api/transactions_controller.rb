module Api
  class TransactionsController < BaseController
    doorkeeper_for :all

    def index
      expose user.transactions
    end

    def show
      expose user.transactions.find(params[:id])
    end

  end
end