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
      head_timestamp = params[:ts]
      raise Exception.new("You must send ts in the query") unless head_timestamp
      tail_timestamp = params[:tail_ts] if params[:tail_ts]
      tail_skip = params[:tail_skip].to_i if params[:tail_skip]

      errors = []
      if params[:data]
        data = params[:data] 
        errors = import_data(data)
      end
      # update the user record with last sync time (now)
      current_resource_owner.update_attribute(:sync_timestamp, Time.now)

      now = Time.now

      # return the sync data from the head forward and tail backward
      head_date = Time.at(head_timestamp.to_i) if head_timestamp.to_i >= 0
      head_date = Time.at(now.to_i + head_timestamp.to_i) if head_timestamp.to_i < 0 # Relative
      if tail_timestamp
        tail_date = Time.at(tail_timestamp.to_i) if tail_timestamp.to_i >= 0
        tail_date = Time.at(now.to_i + tail_timestamp.to_i) if tail_timestamp.to_i < 0 # Relative
      end
      data = export_data(head_date, tail_date, tail_skip)
      data[:errors] = errors
      expose data
    end

    protected

      def import_data(data)
        errors = []
        User::COLLECTIONS.each do |collection_key|
          if data[collection_key]
            if collection_key == :transactions
              begin
                Transaction.import(data[collection_key], current_resource_owner)
              rescue => e
                logger.error(e.class.name + ": " + e.message)
                logger.debug e.backtrace.join("\n")
                errors << e.class.name
              end
              next
            end
            data[collection_key].each do |record|
              relation = current_resource_owner.send(collection_key)
              # Ignore bad data and continue
              # TODO: Notify admin?
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
                errors << e.class.name
              end
            end
          end
        end
        # Note: Actions must be handled after sync, as they may refer to synced items
        if data[:actions]
          data[:actions].each do |action|
            # Ignore bad data and continue
            # TODO: Notify admin?
            begin
              type = action[:action]
              case type
              when 'challenge'
                if action[:challenge][:_id]
                  challenge_id = action[:challenge][:_id]
                  # Dirty hack to fix broken mongoid
                  challenge_id = action[:challenge][:_id][:$oid] if action[:challenge][:_id].is_a?(Hash) && action[:challenge][:_id][:$oid]  
                  c = Challenge.find(challenge_id)
                  c.add_to_set({:subscribers => current_resource_owner.id})
                else
                  c = Challenge.build(action[:challenge])
                  c.creator_id = current_resource_owner.id
                  c.add_to_set({:subscribers => c.creator_id})
                  c.save!
                end
              
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
                  PushNotificationWorker.perform_async(target.id, { 
                                                        :title => "You have been challenged by " + target.to_s,
                                                        :text => "Click to race!"
                                                       })
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
            rescue => e
              logger.error(e.class.name + ": " + e.message)
              logger.debug e.backtrace.join("\n")
              errors << e.class.name
            end
          end
        end
        errors
      end

      def export_data(head_date, tail_date, tail_skip)
        data = {sync_timestamp: Time.now.to_i}

        ### Head forward
        data[:transactions] = []
        transaction = current_resource_owner.latest_transaction 
        data[:transactions] << transaction if transaction
        User::COLLECTIONS.each do |collection_key|
          next if collection_key == :transactions
          data[collection_key] = current_resource_owner.send(collection_key, :unscoped)
                                                       .any_of({:updated_at.gt => head_date},
                                                               {:deleted_at.gt => head_date}).entries()
        end

        ### Tail backward if head is small
        if tail_date && tail_date.to_i > 0
          count = 0
          User::COLLECTIONS.each do |collection_key|
            count += data[collection_key].length
          end

          if count < 5000
            limit = (5000 - count)/5
            tail_skip = 0 unless tail_skip
            User::COLLECTIONS.each do |collection_key|
              next if collection_key == :transactions
              data[collection_key].concat current_resource_owner.send(collection_key, :unscoped)
                                                           .any_of({:updated_at.lte => tail_date},
                                                                   {:deleted_at.lte => tail_date})
                                                           .skip(tail_skip).limit(limit).entries()
            end

            tail_count = 0
            User::COLLECTIONS.each do |collection_key|
              tail_count += data[collection_key].length
            end
            if tail_count > 0
              data[:tail_timestamp] = tail_date.to_i
              data[:tail_skip] = tail_skip + limit
            else
              # Tail fully synced
              data[:tail_timestamp] = 0
              data[:tail_skip] = 0
            end
          end

        end

        data
      end

  end

end
