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
  
      if params[:data]
        data = params[:data] 
        import_data(data)
      end
      # update the user record with last sync time (now)
      current_resource_owner.update_attribute(:sync_timestamp, Time.now)

      # return the sync data from the requested time forward
      date = Time.at(timestamp.to_i)
      expose export_data(date)
    end

    protected

      def import_data(data)
        User::COLLECTIONS.each do |collection_key|
          if data[collection_key]
            data[collection_key].each do |record|
              relation = current_resource_owner.send(collection_key)
              begin
                # Dirty hack to fix broken mongoid
                record[:_id] = record[:_id][:$oid] if record[:_id][:$oid]
                deleted = record[:deleted_at]
                d = relation.new(record)
                d.upsert if d.valid?
                d.delete if deleted
              rescue => e
                logger.error(e.class.name + ": " + e.message)
                logger.debug e.backtrace.join("\n")
              end
            end
          end
        end
        if data[:actions]
          data[:actions].each do |action|
            EchoWorker.perform_async(current_resource_owner.id, action.to_s)
          end
        end
      end

      def export_data(date)
        data = {sync_timestamp: Time.now.to_i}

        User::COLLECTIONS.each do |collection_key|
          data[collection_key] = current_resource_owner.send(collection_key).any_of({:updated_at.gt => date},
                                                                                    {:deleted_at.gt => date})
        end

        data
      end

  end

end
