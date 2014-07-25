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
      # refresh user friends if needed
      current_resource_owner.identities.where('refreshed_at < ?', 5.minutes.ago).each do |id|
        if current_resource_owner.authentications.where(provider: id.provider).last.present?
          # Refresh in background worker
          "#{id.provider.capitalize}FriendsWorker".constantize.perform_async(current_resource_owner.id)
        end
      end

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
        device_id = nil
        errors = []
        User::IMPORT_COLLECTIONS.each do |collection_key|
          if data[collection_key]
            # Special case for getting syncing device
            if collection_key == :devices
              data[collection_key].each do |record|
                begin
                  d = current_resource_owner.devices.new(record)
                  d.merge
                  # Assume first device is the syncing device
                  # TODO: Only ever sync one device
                  device_id = d.id if device_id.nil?
                rescue => e
                  logger.error(e.class.name + ": " + e.message)
                  logger.debug e.backtrace.join("\n")
                  errors << e.class.name
                end
                next
              end
              next
            end
            # Import collection
            clazz = collection_key.to_s.singularize.camelize.constantize
            if clazz.respond_to? :import
              begin
                clazz.import(data[collection_key], current_resource_owner)
              rescue => e
                logger.error(e.class.name + ": " + e.message)
                logger.debug e.backtrace.join("\n")
                errors << e.class.name
              end
              next
            end
            # Merge records individually
            data[collection_key].each do |record|
              relation = current_resource_owner.send(collection_key)
              # Ignore bad data and continue
              # TODO: Notify admin?
              begin
                  record.delete(:user_id)
                  deleted = record[:deleted_at]
                  d = relation.new(record)
                  d.merge
                  d.merge_delete(current_resource_owner) if deleted && deleted != 0
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
              handle_action(action, device_id)
            rescue => e
              logger.error(e.class.name + ": " + e.message)
              logger.debug e.backtrace.join("\n")
              errors << e.class.name
            end
          end
        end
        errors
      end

      def handle_action(action, device_id)
        type = action[:action]
        case type
        when 'challenge'
          c = Challenge.find(action[:challenge_id])
          c.subscribers << current_resource_owner rescue nil
        
          # Notify target of challenge if registered (unregistered are notified client-side)
          if action[:target] && target = User.where(id: action[:target]).first
            c.subscribers << target unless target.id == current_resource_owner.id rescue nil
            message = { 
              :type => 'challenge', 
              :from => current_resource_owner.id, 
              :to => target.id,
              :device_id => c.device_id,
              :challenge_id => c.challenge_id,
              :challenge_type => c.challenge_type,
              :taunt => action[:taunt]
            }
            target.notifications.create( 
                :message => message
            )
            current_resource_owner.notifications.create( 
                :message => message
            )
            PushNotificationWorker.perform_async(target.id, { 
                                                  :title => current_resource_owner.to_s + " has challenged you!",
                                                  :text => "Click to race!",
                                                  :image => current_resource_owner.image_url
                                                 })
            c.touch
            Accumulator.add('challenges_sent', current_resource_owner.id, 1)
          end
        when 'accept_challenge'
          challenge_cid = action[:challenge_id]
          current_resource_owner.challenge_subscribers.find(challenge_cid).update!(accepted: true)
          Challenge.find(challenge_cid).touch
        when 'challenge_attempt'
          challenge_cid = action[:challenge_id]
          challenge_cid[0] = device_id if challenge_cid[0] == 0 # Deferred device registration
          challenge = Challenge.find(challenge_cid)
          track_cid = action[:track_id]
          track_cid[0] = device_id if track_cid[0] == 0 # Deferred device registration
          track = Track.find(track_cid)
          challenge.attempts << track rescue nil
          challenge.touch
          if action[:notification_id]
            notification = Notification.find(action[:notification_id])
            other_id = notification.message['from']
            if current_resource_owner.id != other_id
              PushNotificationWorker.perform_async(other_id, { 
                :title => current_resource_owner.to_s + " has responded to your challenge!",
                :text => "Click to open app!",
                :image => current_resource_owner.image_url
              }) 
              track.track_subscribers.create(user_id: other_id) rescue nil
            end
          end
        when 'share_activity'
          notification = Notification.find(action[:notification_id])
          challenge = nil
          challenge = Challenge.find([notification.message['device_id'], notification.message['challenge_id']]) if notification.message['type'] = 'challenge'
          notification.user.friends.each do |friendship|
            friend = friendship.friend.user
            if friend
              if challenge
                challenge.subscribers << friend rescue nil
                to = notification.message['to']
                from = notification.message['from']
                tracks = challenge.attempts.where(user_id: [to, from].compact)
                tracks.each do |track|
                  track.subscribers << friend rescue nil
                end
              end
              friend.notifications.create(message: notification.message)
            end
          end
          challenge.touch
        else
          #EchoWorker.perform_async(current_resource_owner.id, action)
          logger.error("Unknown action: #{action.to_s}");
        end
      end

      def export_data(head_date, tail_date, tail_skip)
        data = Hash.new
        data[:sync_timestamp] = Time.now.to_i

        ### Head forward
        data[:transactions] = []
        transaction = current_resource_owner.latest_transaction 
        data[:transactions] << transaction if transaction
        data[:counters] = current_resource_owner.accumulators
        User::EXPORT_COLLECTIONS.each do |collection_key|
          data[collection_key] = current_resource_owner.send(collection_key).with_deleted
                                                       .where('updated_at > :head OR deleted_at > :head', 
                                                              {head: head_date})
                                                       .entries()
        end

        ### Tail backward if head is small
        if tail_date && tail_date.to_i > 0
          count = 0
          User::EXPORT_COLLECTIONS.each do |collection_key|
            count += data[collection_key].length
          end

          if count < 5000
            limit = (5000 - count)/5
            tail_skip = 0 unless tail_skip
            User::EXPORT_COLLECTIONS.each do |collection_key|
              data[collection_key].concat current_resource_owner.send(collection_key).with_deleted
                                                                 .where('updated_at <= :tail or deleted_at <= :tail', 
                                                                        {tail: tail_date})
                                                                 .offset(tail_skip).limit(limit).entries()
            end

            tail_count = 0
            User::EXPORT_COLLECTIONS.each do |collection_key|
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
