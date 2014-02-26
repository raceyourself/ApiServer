class GplusShareTrackWorker < ShareTrackWorker
    
  def share(user, track, message)
    auth = Authentication.where(provider: 'gplus', user_id: user.id).first
    raise "User has not authenticated with gplus" if auth.nil?
    raise "User has not authorized share permissions for gplus" if auth.permissions !~ /share/
    client = Google::APIClient.new()
    plus = client.discovered_api('plus')
    client.authorization.client_id = CONFIG[:gplus][:client_id]
    client.authorization.client_secret = CONFIG[:gplus][:client_secret]
    client.authorization.access_token = auth.token
    client.authorization.refresh_token = auth.refresh_token
    result = client.execute(
                :api_method => plus.moments.insert,
                :parameters => {'collection' => 'vault', 'userId' => 'me'},
                :body_object => {
                  'type' => 'http://schemas.google.com/AddActivity',
                  'target' => { 'url' => 'http://lotophage.com/alt_/glass_act' }
                  # Optional startDate
                }
    )
    # TODO: Remove share perms if request fails
    logger.info { "moo!" + result.status.to_s }
    result
  end
    
end
