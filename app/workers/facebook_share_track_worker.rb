class FacebookShareTrackWorker < ShareTrackWorker
    
  def share(user, track, message)
    auth = Authentication.where(provider: 'facebook', user_id: user.id).first
    raise "User has not authenticated with facebook" if auth.nil?
    raise "User has not authorized share permissions for facebook" if auth.permissions !~ /share/
    url = @@external_web_url + 'tracks/' + track.id
    graph = Koala::Facebook::API.new(auth.token)
    if (false)
      course = graph.put_connections("me", "objects/fitness.course", :object => {
          'app_id' =>  CONFIG[:facebook][:client_id],
          'type' => 'fitness.course',
          'title' => track.track_name,
          'url' => url
      }.to_json)
      # TODO: Store course id in case we need to update it
    end
    graph.put_connections("me", "fitness.runs", :course => url)
    # TODO: Catch errors and remove share permission when needed
  end
    
end
