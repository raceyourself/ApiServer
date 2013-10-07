#TODO Should be refactored to use a single db call on fetch

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

      date = Time.at(timestamp.to_i)
      
      if params[:data]
        data = params[:data] 
        import_data(data)
      end
      # update the user record
      current_resource_owner.update_attribute(:sync_timestamp, date)

      # return the sync data
      expose export_data(date)
    end

    protected

      def import_data(data)
        User::COLLECTIONS.each do |collection_key|
          if data[collection_key]
            data[collection_key].each do |record|
              relation = current_resource_owner.send(collection_key)
              if record[:id] && current_record = relation.find(record[:id])
                current_record.update(record)
              else
                relation.create(record)
              end
            end
          end
        end
      end

      def export_data(date)
        data = {sync_timestamp: date.to_i}

        User::COLLECTIONS.each do |collection_key|
          data[collection_key] = current_resource_owner.send(collection_key).where(:updated_at.gt => date)
        end

        data
      end

  end

end