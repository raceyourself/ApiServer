module Api
  class DataController < BaseController
    doorkeeper_for :all

    def index

    end

    def create

    end

    def delayed_create

    end

    def sync
      timestamp = params[:ts]
      raise Exception.new("You must send ts in the query") unless timestamp

      expose export_data(timestamp)
    end

    protected

      def import_data

      end

      def export_data(timestamp)
        data = {}
        
        User::COLLECTIONS.each do |collection_key|
          data[collection_key] = current_resource_owner.send(collection_key).where('updated_at > ?',timestamp)
        end

        data
      end

  end

end