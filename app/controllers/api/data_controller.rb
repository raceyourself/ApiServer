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
                record[:_id] = record[:_id][:$oid] if record[:_id] && record[:_id][:$oid]
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
            type = action[:action]
            case type
            when 'challenge'
              deleted = action[:challenge][:deleted_at]
              c = Challenge.build(action[:challenge])
              c.creator_id = current_resource_owner.id
              c.upsert if c.valid?
              c.delete if deleted
            
              # Notify target of challenge if registered (unregistered are notified client-side)
              if action[:target] && target = User.where(id: action[:target]).first
                message = { 
                  :type => 'challenge', 
                  :from => current_resource_owner.id, 
                  :challenge => c.serializable_hash(:methods => :type), 
                  :taunt => action[:taunt] 
                }
                target.notifications.create( 
                    :message => message
                ) 
              end
            when 'share'
              provider = action[:provider]
              case provider
              when 'facebook'
                FacebookShareTrackWorker.perform_async(current_resource_owner.id,
                                                       action[:track], action[:message])
              when 'twitter'
                TwitterShareTrackWorker.perform_async(current_resource_owner.id,
                                                      action[:track], action[:message])
              when 'google+'
                GplusShareTrackWorker.perform_async(current_resource_owner.id,
                                                    action[:track], action[:message])
              end
            when 'link'
              LinkTrackWorker.perform_async(current_resource_owner.id,
                                            action[:friend_id],
                                            action[:track], action[:message])
            else
              EchoWorker.perform_async(current_resource_owner.id, action)
            end
          end
        end
      end

      def export_data(date)
        data = {sync_timestamp: Time.now.to_i}

        User::COLLECTIONS.each do |collection_key|
          data[collection_key] = current_resource_owner.send(collection_key, :unscoped)
                                                       .any_of({:updated_at.gt => date},
                                                               {:deleted_at.gt => date})
        end

        data
      end

  end

end
