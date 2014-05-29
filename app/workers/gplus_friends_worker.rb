require 'google/api_client'
class GplusFriendsWorker
  include Sidekiq::Worker

  @@FAIL_FAST = true

  def perform(user_id)
    user = User.where(id: user_id).first
    auth = Authentication.where(provider: 'gplus', user_id: user.id).last
    client = Google::APIClient.new()
    plus = client.discovered_api('plus')
    client.authorization.client_id = CONFIG[:gplus][:client_id]
    client.authorization.client_secret = CONFIG[:gplus][:client_secret]
    client.authorization.access_token = auth.token
    client.authorization.refresh_token = auth.refresh_token
    result = client.execute(
      :api_method => plus.people.get, 
      :parameters => {'userId' => 'me'}
    )
    me = GplusIdentity.new().update_from_gplus(result.data)
    me.user_id = user.id
    me = me.merge
    return if me.refreshed_at > 5.minutes.ago
    ActiveRecord::Base.transaction do
      me.update!(:refreshed_at => Time.now)
      me.friendships.where(:friend_type => 'GplusIdentity').destroy_all
      req = {
          :api_method => plus.people.list, 
          :parameters => {'collection' => 'visible', 'userId' => 'me'}
      }
      begin
        result = client.execute(req)
        result.data.items.each do |person|
          fid = GplusIdentity.new().update_from_gplus(person)
          fid = fid.merge
          fs = Friendship.new( identity: me, friend: fid )
          fs = fs.merge
        end
        if result.next_page_token
          req = result.next_page
        else
          req = nil
        end
      end while not req.nil?
    end
  end

end
