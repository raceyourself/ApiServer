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
                record[:_id] = record[:_id][:$oid] if record[:_id] && record[:_id].is_a?(Hash) && record[:_id][:$oid]
                deleted = record[:deleted_at]
                d = relation.new(record)
                d.merge
                d.delete if deleted && deleted != 0
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
              c = Challenge.build(action[:challenge])
              c.creator_id = current_resource_owner.id
              c.add_to_set({:subscribers => c.creator_id})
              c.save!
            
              # Notify target of challenge if registered (unregistered are notified client-side)
              if action[:target] && target = User.where(id: action[:target]).first
                c.add_to_set({:subscribers => target.id})
                message = { 
                  :type => 'challenge', 
                  :from => current_resource_owner.id, 
                  :challenge_id => c.id, 
                  :taunt => action[:taunt] 
                }
                target.notifications.create( 
                    :message => message
                ) 
              end
            when 'challenge_attempt'
              challenge_id = action[:challenge_id]
              # Dirty hack to fix broken mongoid
              challenge_id = action[:challenge_id][:$oid] if action[:challenge_id].is_a?(Hash) && action[:challenge_id][:$oid]
              challenge = Challenge.find(challenge_id)
              track_cid = action[:track_id]
              track = Track.where(device_id: track_cid[0], track_id: track_cid[1]).first
              challenge.attempts << track
              challenge.save!
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
