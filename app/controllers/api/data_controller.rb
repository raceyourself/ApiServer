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
                record.delete(:user_id)
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
                                                        :title => current_resource_owner.to_s + " has challenged you!",
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
              when 'invite'
                code = action[:code]
                invite = Invite.where(:code => code)
                               .where(:user_id => current_resource_owner.id)
                               .where('used_at IS NULL')
                               .where('expires_at IS NULL or expires_at < ?', Time.now).first
                if invite
                  provider = action[:provider]
                  uid = action[:uid]
                  invite.update_attributes!({:identity_type => provider, :identity_uid => uid, :used_at => Time.now})
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
        data[:devices] = current_resource_owner.send(:devices)
                                                     .where('updated_at > :head', 
                                                            {head: head_date})
                                                     .entries()
        data[:transactions] = []
        transaction = current_resource_owner.latest_transaction 
        data[:transactions] << transaction if transaction
        User::COLLECTIONS.each do |collection_key|
          next if collection_key == :transactions
          next if collection_key == :events
          next if collection_key == :devices
          data[collection_key] = current_resource_owner.send(collection_key).with_deleted
                                                       .where('updated_at > :head OR deleted_at > :head', 
                                                              {head: head_date})
                                                       .entries()
        end

        ### Tail backward if head is small
        if tail_date && tail_date.to_i > 0
          count = 0
          User::COLLECTIONS.each do |collection_key|
            next if collection_key == :transactions
            next if collection_key == :events
            count += data[collection_key].length
          end

          if count < 5000
            limit = (5000 - count)/5
            tail_skip = 0 unless tail_skip
            User::COLLECTIONS.each do |collection_key|
              next if collection_key == :transactions
              next if collection_key == :events
              next if collection_key == :devices
              data[collection_key].concat current_resource_owner.send(collection_key).with_deleted
                                                                 .where('updated_at <= :tail or deleted_at <= :tail', 
                                                                        {tail: tail_date})
                                                                 .offset(tail_skip).limit(limit).entries()
            end

            tail_count = 0
            User::COLLECTIONS.each do |collection_key|
              next if collection_key == :transactions
              next if collection_key == :events
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
